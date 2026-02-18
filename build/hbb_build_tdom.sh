#!/bin/bash

tclversion=8.6.14
tclwinshortversion=86
prog=tdom
version=0.9.4
url=http://tdom.org/downloads/tdom-$version-src.tgz

# This script builds tdom using the Holy build box environment
# and installs them in dirtcl
# options:
# -b|-bits|--bits: 32 for 32 bits build (default 64)
# -d|-builddir|--builddir: top directory to build in (default ~/build/tcl$arch)
# -v|-version|--version: tcl version (default $tclversion)
# dirtcl should be build before usong hbb_build_dirtcl.sh with the same options
# The extensions are placed in the ext dir of the dirtcl

# The Holy build box environment requires docker, make sure it is installed
# e.g. on ubuntu and derivatives
# sudo apt install docker.io
# Also make sure you have permission to use docker
# sudo usermod -a -G docker $USER

# stop on error
set -e

# print all executed commands to the terminal
set -x

# Prepare and start docker with Holy Build box
# ============================================

script="$(readlink -f "$0")"
dir="$(dirname "$script")"
source "${dir}/start_hbb.sh"

# Parse arguments
# ===============

while [[ "$#" -gt 0 ]]; do case $1 in
    -v|-version|--version) tclversion="$2"; shift;;
    *) echo "Unknown parameter: $1"; exit 1;;
esac; shift; done

tclshortversion=${tclversion%.*}

# Script run within Holy Build box
# ================================

# The normal Holy Build Box environment
# will try to compile with static libs
# As this does not work for some of the 
# packages we want to build,
# we do not activate Holy Build Box environment.
# HBB is in this case only used for glibc compat, not static libs
# source /hbb_shlib/activate

# set up environment
# ------------------

# put dirtcl tclsh in PATH
mkdir /build/bin || true
cd /build/bin
ln -sf $dirtcldir/tclsh.exe .

# locations
PATH=/build/bin:$PATH
tcldir=/build/tcl$tclversion
tkdir=/build/tk$tclversion
dirtcldir=/build/dirtcl$tclversion-$arch
destdir=$dirtcldir/exts

if [ $arch = "linux-x86_64" ] || [ $arch = "windows-x86_64" ]; then
    yuminstall devtoolset-9
    ## use source instead of scl enable so it can run in a script
    ## scl enable devtoolset-9 bash
    source /opt/rh/devtoolset-9/enable
fi
if [[ $arch =~ "linux" ]]; then
    # X libraries are needed to make Tk, wget to download from sourceforge
#    yuminstall libX11-devel
    CROSSCOMPILE=""
    # ln -s $dirtcldir/tclsh /build/bin/tclsh
else
    yuminstall wine
    CROSSCOMPILE="--host=$HOST --build=x86_64-linux"
    echo -e "#"'!'"/bin/bash\nWINEDEBUG=-all wine $dirtcldir/tclsh$tclwinshortversion.exe \$@\n" > /build/bin/tclsh
    chmod ug+x /build/bin/tclsh
    cp /build/bin/tclsh /build/bin/tclsh8.5
fi
yuminstall wget

# Build
# -----

mkdir /build/packages || true
cd /build/packages

# tdom
# ----
if [ "$arch" = "windows-x86_64" ] ; 	then
	mkdir /build/packages/tdom-$version-$arch
	cd /build/packages/tdom-$version-$arch
	wget https://teapot.activestate.com/package/name/tdom/ver/$version/arch/win32-x86_64/file.zip
	unzip file.zip
	rm file.zip
	target=$dirtcldir/exts/$prog$version
	rm -rf $target
	mkdir $target
	cp -a * $target
	echo 'package require Tcl 8.4
load [file join $dir tdom083.dll] tdom
source [list [file join $dir tdom.tcl]]
' > $target/init.tcl

else 
	target=$dirtcldir/exts/$prog$version
	cd /build/packages
	wget -c --no-check-certificate $url
	# tar xvzf tdom_0_8_3_postrelease.tar.gz
	# cd tdom-tdom_0_8_3_postrelease
	tar xvzf tdom-$version-src.tgz
	cd /build/packages/tdom-$version-src
	mv generic/tclexpat.c generic/tclexpat.c.ori || true
	# patch: code used strlen as a variable name, causing compile errors (clashes with the lib function)
	cp /io/build/patches/tdom-0-9-4-tclexpat.c generic/tclexpat.c
	# patch: The Tcl_PkgProvide* in the code caused circular package dependency errors (for reasons I could not figure out)
	# commented them out, and do package provide in tcl init code
	cp generic/tdominit.c generic/tdominit.c.ori || true
	sed -i 's/^\([[:space:]]*\)Tcl_PkgProvide(interp, PACKAGE_NAME, PACKAGE_VERSION);/\1\/\* & \*\//' generic/tdominit.c
	sed -i '/Tcl_PkgProvideEx(interp, PACKAGE_NAME, PACKAGE_VERSION,/{N;s/\(Tcl_PkgProvideEx(interp, PACKAGE_NAME, PACKAGE_VERSION,[[:space:]]*\n[[:space:]]*(ClientData) &tdomStubs);\)/\/\* \1 \*\//}' generic/tdominit.c
	# compile
	make distclean || true
	./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --disable-stubs --enable-64bit $CROSSCOMPILE
	make
	make install
	rm -rf /build/dirtcl$tclversion-x86_64/man || true
	rm -rf $target || true
	mv $dirtcldir/lib/$prog$version $target
	rm -f $target/init.tcl || true
	rm -f $target/pkgIndex.tcl || true
#	cp -f /io/packages/$prog$version-init.tcl $target/init.tcl
#	cp -f /io/packages/$prog$version-pkgIndex.tcl $target/pkgIndex.tcl
	echo "package require pkgtools
load [file join \$dir [pkgtools::architecture] libtdom$version.so]
package provide tdom $version
source [file join \$dir tdom.tcl]
extension provide tdom $version" > $target/init.tcl
	echo "package ifneeded tdom $version \"package require pkgtools ; load \[file join [list \$dir] \[pkgtools::architecture\] libtdom$version.so\] ; package provide tdom $version ; source [file join \$dir tdom.tcl] ; extension provide tdom $version\"" > $target/pkgIndex.tcl
	rm -rf "$target/$arch"
	mkdir "$target/$arch"
	mv "$target/libtdom$version.so" "$target/$arch"
	rm "$target/libtdomstub$version.a"
fi

echo "Finished building $prog in $builddir/dirtcl$tclversion-$arch/exts/$prog$version"
