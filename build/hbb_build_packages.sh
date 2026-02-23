#!/bin/bash

#tclversion=8.6.14
#tclwinshortversion=86
tclversion=9.0.3
tclmajorversion=9
tclwinshortversion=90

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
PATH=/build/bin:$PATH

# locations
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

## Extral
## ------
#version=2.1.0
#cd /build/packages
#wget -c --no-check-certificate https://sourceforge.net/projects/extral/files/Extral-$version.src.tar.gz
#tar xvzf Extral-$version.src.tar.gz
#rm -rf Extral-$version
#mv Extral Extral-$version || true
#cd /build/packages/Extral-$version
#cp Makefile.in Makefile.in.ori || true
#sed 's/@TCLSH_PROG@/tclsh/g' Makefile.in.ori > Makefile.in
#rm -rf $arch
#mkdir $arch || true
#cd $arch
#make distclean || true
#../configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" $CROSSCOMPILE
#make
#rm -rf $destdir/Extral-$version
#tclsh ../build/install.tcl $destdir
#chown -R $uid.$gid $destdir/Extral-$version
#
## ClassyTcl
## ---------
#version=1.1.0
#cd /build/packages
#wget -c --no-check-certificate https://sourceforge.net/projects/classytcl/files/ClassyTcl-$version-src.tar.gz
#tar xvzf ClassyTcl-$version-src.tar.gz
#mv ClassyTcl ClassyTcl-$version || true
#cd /build/packages/ClassyTcl-$version
#cp Makefile.in Makefile.in.ori || true
#sed 's/@TCLSH_PROG@/tclsh/g' Makefile.in.ori > Makefile.in
#rm -rf $arch
#mkdir $arch
#cd $arch
#make distclean || true
#../configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" $CROSSCOMPILE
#make
#rm -rf $destdir/Class$version
#tclsh ../build/install.tcl $destdir
#chown -R $uid.$gid $destdir/Class$version
#
## ClassyTk
## ---------
#prog=ClassyTk
#version=1.1.0
#cd /build/packages
#wget -c --no-check-certificate https://sourceforge.net/projects/classytcl/files/$prog-$version-src.tar.gz
#tar xvzf $prog-$version-src.tar.gz
#mv $prog $prog-$version || true
#cd /build/packages/$prog-$version
#cp Makefile.in Makefile.in.ori || true
#sed 's/@TCLSH_PROG@/tclsh/g' Makefile.in.ori > Makefile.in
#rm -rf $arch
#mkdir $arch
#cd $arch
#make distclean || true
#../configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib"
#make
#rm -rf $destdir/$prog-$version
#tclsh ../build/install.tcl $destdir
#chown -R $uid.$gid $destdir/$prog-$version
#
## sqlite
## ------
#cd /build/
#sqliteversion=3390300
#sqliteyear=2022
#wget -c --no-check-certificate https://www.sqlite.org/$sqliteyear/sqlite-autoconf-$sqliteversion.tar.gz
#tar xvzf sqlite-autoconf-$sqliteversion.tar.gz
#cd /build/sqlite-autoconf-$sqliteversion
#make distclean
##CFLAGS="-fPIC -Os -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1 -DSQLITE_ENABLE_RTREE=1" \
##./configure --enable-shared --enable-static --enable-threadsafe --enable-dynamic-extensions $CROSSCOMPILE
#./configure --disable-shared --enable-static --enable-threadsafe --enable-dynamic-extensions $CROSSCOMPILE
#make
#sudo make install
#sudo rm /usr/local/lib/libsqlite3.so*
#
## dbi
## ---
#prog=dbi_sqlite3
#version=1.0.0
#url=http://sourceforge.net/projects/tcl-dbi/files/dbi-1.0.0-src.tar.gz
#target=$dirtcldir/exts/$prog-$version
#cd /build/packages
#wget -c --no-check-certificate $url
#tar xvzf dbi-$version-src.tar.gz
#mv dbi dbi$version || true
#cd /build/packages/dbi$version/sqlite3
#cp Makefile.in Makefile.in.ori || true
#sed 's/@TCLSH_PROG@/tclsh/g' Makefile.in.ori > Makefile.in
#rm -rf $arch
#mkdir $arch || true
#cd $arch
#make distclean || true
#../configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" $CROSSCOMPILE
#make
#cp /io/packages/dbi_sqlite3-1.0.0-pkgIndex.tcl ../pkgIndex.tcl
#rm -rf $dirtcldir/exts/dbi_sqlite3-$version
#../build/install.tcl $dirtcldir/exts

# rbc
# ---

prog=rbc
if [ "$tclmajorversion" = "9" ] ; 	then
	version=0.2
	fversion=0.2.0
	if [ "$arch" = "windows-x86_64" ] ; 	then
		mkdir /build/packages/$prog-$version-$arch
		cd /build/packages/$prog-$version-$arch
		wget https://teapot.activestate.com/package/name/$prog/ver/$version/arch/win32-x86_64/file.zip
		unzip file.zip
		rm file.zip
		target=$dirtcldir/exts/$prog$version
		rm -rf $target
		mkdir $target
		cp -a * $target
		echo 'package require Tk
	load [file join $dir rbc0.1.dll] 
	source [file join $dir graph.tcl]' > $target/init.tcl
	else 
		target=$dirtcldir/exts/$prog$fversion
		cd /build/packages
		tar xvzf /io/packages/$prog-tk9-$version.tar.gz
		cd /build/packages/$prog-tk9-$version
		make distclean
		LDFLAGS='-static-libgcc -static-libstdc++' ./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --with-tk="$dirtcldir/lib" $CROSSCOMPILE
		WIN32=1 make install
		rm -rf $dirtcldir/exts/$prog$fversion
		mv $dirtcldir/lib/$prog$fversion $dirtcldir/exts
		rm -f $target/init.tcl
		cp -f /io/packages/$prog-0.1-init.tcl $target/init.tcl
		rm -f $target/pkgIndex.tcl
		sed 's/0.1/0.2.0/g' /io/packages/$prog-0.1-pkgIndex.tcl > $target/pkgIndex.tcl
		rm -rf "$target/$arch"
		mkdir "$target/$arch"
		mv $target/lib*$prog$fversion.so "$target/$arch/lib$prog$version.so"
	fi
else
	version=0.1
	if [ "$arch" = "windows-x86_64" ] ; 	then
		mkdir /build/packages/$prog-$version-$arch
		cd /build/packages/$prog-$version-$arch
		wget https://teapot.activestate.com/package/name/$prog/ver/$version/arch/win32-x86_64/file.zip
		unzip file.zip
		rm file.zip
		target=$dirtcldir/exts/$prog$version
		rm -rf $target
		mkdir $target
		cp -a * $target
		echo 'package require Tk
	load [file join $dir rbc0.1.dll] 
	source [file join $dir graph.tcl]' > $target/init.tcl
	else 
		target=$dirtcldir/exts/$prog$version
		cd /build/packages
		wget -c --no-check-certificate http://sourceforge.net/projects/genomecomb/files/deps/$prog-$version-src.tar.gz
		tar xvzf $prog-$version-src.tar.gz
		cd /build/packages/$prog
		make distclean
		LDFLAGS='-static-libgcc -static-libstdc++' ./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --with-tk="$dirtcldir/lib" $CROSSCOMPILE
		WIN32=1 make install
		rm -rf $dirtcldir/exts/$prog$version
		mv $dirtcldir/lib/$prog$version $dirtcldir/exts
		rm -f $target/init.tcl
		cp -f /io/packages/$prog-$version-init.tcl $target/init.tcl
		rm -f $target/pkgIndex.tcl
		cp /io/packages/$prog-$version-pkgIndex.tcl $target/pkgIndex.tcl
		rm -rf "$target/$arch"
		mkdir "$target/$arch"
		mv "$target/lib$prog$version.so" "$target/$arch"
	fi
fi

# Tktable
# -------
if [ "$arch" = "windows-x86_64" ] ; 	then
	version=2.11
	mkdir /build/packages/tktable-$version-$arch
	cd /build/packages/tktable-$version-$arch
	wget https://teapot.activestate.com/package/name/Tktable/ver/$version/arch/win32-x86_64/file.zip
	unzip file.zip
	rm file.zip
	target=$dirtcldir/exts/$prog$version
	rm -rf $target
	mkdir $target
	cp -a * $target
	echo 'package require Tcl 8.2
load [file join $dir Tktable211.dll] Tktable
extension provide Tktable 2.11' > $target/init.tcl
else 
	prog=Tktable
	version=2.12.1
	# url=http://sourceforge.net/projects/tktable/files/tktable/$version/$prog$version.tar.gz
	# generic sourceforge url no longer seems to work within HBB, so use direct link (to one of the mirrors)
	# url=https://netcologne.dl.sourceforge.net/project/tktable/tktable/$version/$prog$version.tar.gz
	# new version (compatible with Tcl9) from github
	url=https://github.com/bohagan1/TkTable/releases/download/tktable-2-12-1/tktable-2.12.1-src.tar.gz
	target=$dirtcldir/exts/$prog$version
	cd /build/packages
	wget -c $url
	tar xvzf tktable-$version-src.tar.gz
	cd tktable-35d3f2fa4d/
	make distclean || true
	./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --with-tk="$dirtcldir/lib" $CROSSCOMPILE
	make install
	rm -rf $dirtcldir/exts/$prog$version
	mv $dirtcldir/lib/$prog$version $dirtcldir/exts
	rm -f $target/init.tcl
	cp -f /io/packages/$prog$version-init.tcl $target/init.tcl
	# rm -f $target/pkgIndex.tcl
	# cp /io/packages/$prog$version-pkgIndex.tcl $target/pkgIndex.tcl
	rm -rf "$target/$arch"
	mkdir "$target/$arch"
	mv $target/lib*$version.so "$target/$arch/libTktable2.12.1.so"
fi

## Tclx
## ----
#prog=Tclx
#version=8.6.3
#shortversion=8.6
#url=https://github.com/flightaware/tclx/archive/refs/tags/v8.6.3.tar.gz
#
#if [ "$arch" = "windows-x86_64" ] ; 	then
#	mkdir /build/packages/Tclx-$version-$arch
#	cd /build/packages/Tclx-$version-$arch
#	wget https://teapot.activestate.com/package/name/Tclx/ver/8.4/arch/win32-x86_64/file.zip
#	unzip file.zip
#	rm file.zip
#	target=$dirtcldir/exts/$prog$version
#	rm -rf $target
#	mkdir $target
#	cp -a * $target
#	echo 'if {![package vsatisfies [package provide Tcl] 8.4]} return
#package ifneeded Tclx 8.4 [string map [list @ $dir] {
#        package require Tcl 8.4
#            set ::env(TCLX_LIBRARY) {@}
#            load [file join {@} tclx84.dll] Tclx
#        package provide Tclx 8.4
#    }]
#' > $target/pkgIndex.tcl
#	echo 'package require Tcl 8.4
#set ::env(TCLX_LIBRARY) $dir
#load [file join $dir tclx84.dll] Tclx
#extension provide Tclx 8.4' > $target/init.tcl
#
#else 
#	target=$dirtcldir/exts/$prog$version
#	# url=http://sourceforge.net/projects/tclx/files/TclX/$version.0/tclx$version.tar.bz2
#	cd /build/packages
#	wget -c --no-check-certificate $url
#	mv v$version.tar.gz tclx$version.tar.gz
#	tar xvzf tclx$version.tar.gz
#	cd /build/packages/tclx-$version
#	make distclean || true
#	./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" $CROSSCOMPILE
#	make install
#	rm -rf /build/dirtcl$tclversion-x86_64/man
#	rm -rf $target
#	mv $dirtcldir/lib/tclx$shortversion $target
#	mkdir $target/$arch
#	mv $target/libtclx$shortversion.so $target/$arch/libtclx$version.so
#	echo "package require pkgtools
#set env(TCLX_LIBRARY) \$dir/lib
#load [file join \$dir [pkgtools::architecture] libtclx$version.so] Tclx
#" > $target/init.tcl
#	echo "package ifneeded Tclx $version \"package require pkgtools ; set env(TCLX_LIBRARY) \$dir/lib ; load \[file join [list \$dir] \[pkgtools::architecture\] libtclx$version.so\] \"" > $target/pkgIndex.tcl
#fi

# tdom
# ----
prog=tdom
#version=0.8.3
#url=https://github.com/tDOM/tdom/archive/tdom_0_8_3_postrelease.tar.gz
version=0.9.6
url=http://tdom.org/downloads/tdom-$version-src.tgz
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
#	mv generic/tclexpat.c generic/tclexpat.c.ori || true
#	# patch: code used strlen as a variable name, causing compile errors (clashes with the lib function)
#	cp /io/build/patches/tdom-0-9-4-tclexpat.c generic/tclexpat.c
#	# patch: The Tcl_PkgProvide* in the code caused circular package dependency errors (for reasons I could not figure out)
#	# commented them out, and do package provide in tcl init code
#	cp generic/tdominit.c generic/tdominit.c.ori || true
#	sed -i 's/^\([[:space:]]*\)Tcl_PkgProvide(interp, PACKAGE_NAME, PACKAGE_VERSION);/\1\/\* & \*\//' generic/tdominit.c
#	sed -i '/Tcl_PkgProvideEx(interp, PACKAGE_NAME, PACKAGE_VERSION,/{N;s/\(Tcl_PkgProvideEx(interp, PACKAGE_NAME, PACKAGE_VERSION,[[:space:]]*\n[[:space:]]*(ClientData) &tdomStubs);\)/\/\* \1 \*\//}' generic/tdominit.c
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
if {[package vsatisfies [package provide Tcl] 9.0-]} {
	load [file join \$dir [pkgtools::architecture] libtcl9tdom$version.so]
} else {
	load [file join \$dir [pkgtools::architecture] libtdom$version.so]
}
package provide tdom $version
source [file join \$dir tdom.tcl]
extension provide tdom $version" > $target/init.tcl
	echo "package ifneeded tdom $version \"set dir \$dir ; source \[file join [list \$dir] init.tcl\]\"" > $target/pkgIndex.tcl
	rm -rf "$target/$arch"
	mkdir "$target/$arch"
	mv $target/lib*.so "$target/$arch"
	rm $target/lib*.a
fi

# expect
# ------
cd /build/packages

# version=5.45.4
# wget -c --no-check-certificate https://sourceforge.net/projects/expect/files/Expect/$version/expect$version.tar.gz
# tar xvzf expect$version.tar.gz
# cd /build/packages/expect$version

version=5.45.4.1
wget -c --no-check-certificate https://www.tcl3d.org/bawt/download/InputLibs/expect-5.45.4.1.7z
yuminstall p7zip
7za x expect-$version.7z
cd /build/packages/expect-$version

rm -rf $arch
mkdir $arch || true
cd $arch
make distclean
chmod u+x ../configure
../configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --enable-shared --disable-static $CROSSCOMPILE
make libexpect$version.so

# make distribution
rm -rf $destdir/Expect-$version
mkdir $destdir/Expect-$version
cp libexpect$version.so $destdir/Expect-$version

echo "package ifneeded Expect 5.45.4 [list load [file join \$dir libexpect$version.so]]\
" > $destdir/Expect-$version/pkgIndex.tcl

echo "load [file join \$dir libexpect$version.so]\
" > $destdir/Expect-$version/init.tcl

chown -R $uid.$gid $destdir/Expect-$version

echo "Finished building packages"
