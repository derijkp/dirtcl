#!/bin/bash

tclversion=8.6.14
tclwinshortversion=86
prog=Tclx
version=8.6.3
shortversion=8.6
url=https://github.com/flightaware/tclx/archive/refs/tags/v8.6.3.tar.gz

# This script builds some packages (tdom, Tclx, expect, rbc, Tktable) using the Holy build box environment
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
    yuminstall libX11-devel
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

# Tclx
# ----

if [ "$arch" = "windows-x86_64" ] ; 	then
	mkdir /build/packages/Tclx-$version-$arch
	cd /build/packages/Tclx-$version-$arch
	wget https://teapot.activestate.com/package/name/Tclx/ver/8.4/arch/win32-x86_64/file.zip
	unzip file.zip
	rm file.zip
	target=$dirtcldir/exts/$prog$version
	rm -rf $target
	mkdir $target
	cp -a * $target
	echo 'if {![package vsatisfies [package provide Tcl] 8.4]} return
package ifneeded Tclx 8.4 [string map [list @ $dir] {
        package require Tcl 8.4
            set ::env(TCLX_LIBRARY) {@}
            load [file join {@} tclx84.dll] Tclx
        package provide Tclx 8.4
    }]
' > $target/pkgIndex.tcl
	echo 'package require Tcl 8.4
set ::env(TCLX_LIBRARY) $dir
load [file join $dir tclx84.dll] Tclx
extension provide Tclx 8.4' > $target/init.tcl

else 
	target=$dirtcldir/exts/$prog$version
	# url=http://sourceforge.net/projects/tclx/files/TclX/$version.0/tclx$version.tar.bz2
	cd /build/packages
	wget -c --no-check-certificate $url
	mv v$version.tar.gz tclx$version.tar.gz
	tar xvzf tclx$version.tar.gz
	cd /build/packages/tclx-$version
	make distclean || true
	./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" $CROSSCOMPILE
	make install
	rm -rf /build/dirtcl$tclversion-x86_64/man
	rm -rf $target
	mv $dirtcldir/lib/tclx$shortversion $target
	mkdir $target/$arch
	mv $target/libtclx$shortversion.so $target/$arch/libtclx$version.so
	echo "package require pkgtools
set env(TCLX_LIBRARY) \$dir/lib
load [file join \$dir [pkgtools::architecture] libtclx$version.so] Tclx
" > $target/init.tcl
	echo "package ifneeded Tclx $version \"package require pkgtools ; set env(TCLX_LIBRARY) \$dir/lib ; load \[file join [list \$dir] \[pkgtools::architecture\] libtclx$version.so\] \"" > $target/pkgIndex.tcl
fi

echo "Finished building $prog in $builddir/dirtcl$tclversion-$arch/exts/$prog$version"
