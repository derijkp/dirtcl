#!/bin/bash

tclversion=8.5.19

# This script builds some packages using the Holy build box environment
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

# do not activate Holy Build Box environment.
# Some do not compile with these settings (X)
# only use HBB for glibc compat, not static libs
# source /hbb_shlib/activate

# print all executed commands to the terminal
set -x

# set up environment
# ------------------

# X libraries are needed to make Tk, wget to download from sourceforge
yuminstall libX11-devel
yuminstall wget

# locations
tcldir=/build/tcl$tclversion
tkdir=/build/tk$tclversion
dirtcldir=/build/dirtcl$tclversion-$arch
destdir=$dirtcldir/exts

# put dirtcl tclsh in PATH
mkdir /build/bin || true
cd /build/bin
ln -sf $dirtcldir/tclsh .
PATH=/build/bin:$PATH

# Build
# -----

mkdir /build/packages || true
cd /build/packages

# Extral
# ------
version=2.1.0
cd /build/packages
wget -c https://sourceforge.net/projects/extral/files/Extral-$version.src.tar.gz
tar xvzf Extral-$version.src.tar.gz
mv Extral Extral-$version
rm -rf Extral-$version/Linux-i686/
cd Extral-$version
mkdir linux-$arch || true
cd linux-$arch
make distclean || true
../configure --prefix="$dirtcldir"
make
rm -rf $destdir/Extral-$version
tclsh ../build/install.tcl $destdir
chown -R $uid.$gid $destdir/Extral-$version

# ClassyTcl
# ---------
version=1.1.0
cd /build/packages
wget -c https://sourceforge.net/projects/classytcl/files/ClassyTcl-$version-src.tar.gz
tar xvzf ClassyTcl-$version-src.tar.gz
mv ClassyTcl ClassyTcl-$version
cd ClassyTcl-$version
mkdir linux-$arch
cd linux-$arch
make distclean || true
../configure --prefix="$dirtcldir"
make
rm -rf $destdir/Class$version
tclsh ../build/install.tcl $destdir
chown -R $uid.$gid $destdir/Class$version

# ClassyTk
# ---------
prog=ClassyTk
version=1.1.0
cd /build/packages
wget -c https://sourceforge.net/projects/classytcl/files/$prog-$version-src.tar.gz
tar xvzf $prog-$version-src.tar.gz
mv $prog $prog-$version
cd $prog-$version
mkdir linux-$arch
cd linux-$arch
make distclean || true
../configure --prefix="$dirtcldir"
make
rm -rf $destdir/$prog-$version
tclsh ../build/install.tcl $destdir
chown -R $uid.$gid $destdir/$prog-$version

# sqlite
# ------
cd /build/
wget -c https://www.sqlite.org/2019/sqlite-autoconf-3270200.tar.gz
tar xvzf sqlite-autoconf-3270200.tar.gz
cd /build/sqlite-autoconf-3270200
make distclean
CFLAGS="-fPIC -Os -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1 -DSQLITE_ENABLE_RTREE=1" \
./configure --enable-shared --enable-static --enable-threadsafe --enable-dynamic-extensions
make
sudo make install
sudo rm /usr/local/lib/libsqlite3.so*

# dbi
# ---
prog=dbi_sqlite3
version=1.0.0
url=http://sourceforge.net/projects/tcl-dbi/files/dbi-1.0.0-src.tar.gz
target=$dirtcldir/exts/$prog-$version
cd /build/packages
wget -c $url
tar xvzf dbi-$version-src.tar.gz
mv dbi dbi$version
cd /build/packages/dbi$version/sqlite3
make distclean
./configure --prefix="$dirtcldir"
make
cp /io/packages/dbi_sqlite3-1.0.0-pkgIndex.tcl pkgIndex.tcl
rm -rf $dirtcldir/exts/dbi_sqlite3-$version
./build/install.tcl $dirtcldir/exts

# rbc
# ---
prog=rbc
version=0.1
target=$dirtcldir/exts/$prog$version
cd /build/packages
wget -c http://sourceforge.net/projects/genomecomb/files/deps/$prog-$version-src.tar.gz
tar xvzf $prog-$version-src.tar.gz
cd $prog
./configure --prefix="$dirtcldir"
make install
mv $dirtcldir/lib/$prog$version $dirtcldir/exts
rm -f $target/init.tcl
cp -f /io/packages/$prog-$version-init.tcl $target/init.tcl
rm -f $target/pkgIndex.tcl
cp /io/packages/$prog-$version-pkgIndex.tcl $target/pkgIndex.tcl
mkdir "$target/linux-$arch"
mv "$target/lib$prog$version.so" "$target/linux-$arch"

# Tktable
# -------
prog=Tktable
version=2.10
url=http://sourceforge.net/projects/tktable/files/tktable/$version/$prog$version.tar.gz
target=$dirtcldir/exts/$prog$version
cd /build/packages
wget -c $url
tar xvzf $prog$version.tar.gz
cd $prog$version
./configure --prefix="$dirtcldir"
make install
mv $dirtcldir/lib/$prog$version $dirtcldir/exts
rm -f $target/init.tcl
cp -f /io/packages/$prog$version-init.tcl $target/init.tcl
rm -f $target/pkgIndex.tcl
cp /io/packages/$prog$version-pkgIndex.tcl $target/pkgIndex.tcl
mkdir "$target/linux-$arch"
mv "$target/lib$prog$version.so" "$target/linux-$arch"

# Tclx
# ----
prog=Tclx
version=8.4
url=http://sourceforge.net/projects/tclx/files/TclX/$version.0/tclx$version.tar.bz2
target=$dirtcldir/exts/$prog$version
cd /build/packages
wget -c $url
tar xvjf tclx$version.tar.bz2
cd tclx$version
./configure --prefix="$dirtcldir"
make install
rm -rf /build/dirtcl8.5.19-x86_64/man
rm -rf $target
mv $dirtcldir/lib/tclx$version $target
rm -f $target/init.tcl
rm -f $target/pkgIndex.tcl
mkdir $target/lib
mv $target/*.tcl $target/lib
cp -f /io/packages/$prog$version-init.tcl $target/init.tcl
cp /io/packages/$prog$version-pkgIndex.tcl $target/pkgIndex.tcl
mkdir "$target/linux-$arch"
mv "$target/libtclx$version.so" "$target/linux-$arch"

# tdom
# ----
prog=tdom
version=0.8.3
url=https://github.com/tDOM/tdom/archive/tdom_0_8_3_postrelease.tar.gz
target=$dirtcldir/exts/$prog$version
cd /build/packages
wget -c $url
tar xvzf tdom_0_8_3_postrelease.tar.gz
cd tdom-tdom_0_8_3_postrelease
./configure --prefix="$dirtcldir"
make install
rm -rf /build/dirtcl8.5.19-x86_64/man
rm -rf $target
mv $dirtcldir/lib/$prog$version $target
rm -f $target/init.tcl
rm -f $target/pkgIndex.tcl
cp -f /io/packages/$prog$version-init.tcl $target/init.tcl
cp -f /io/packages/$prog$version-pkgIndex.tcl $target/pkgIndex.tcl
mkdir "$target/linux-$arch"
mv "$target/libtdom$version.so" "$target/linux-$arch"
rm "$target/libtdomstub$version.a"

# Change owner and group
# ----------------------
# change user and group on generated files
chown $uid.$gid /build/tcl$tclversion-src.tar.gz /build/tk$tclversion-src.tar.gz
chown -R $uid.$gid /build/tcl$tclversion /build/tk$tclversion /build/dirtcl$tclversion-$arch
chown -h $uid.$gid /build/dirtcl-$arch /build/dirtcl

echo "Finished building packages"
