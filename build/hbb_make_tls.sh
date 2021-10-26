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

# The normal Holy Build Box environment
# will try to compile with static libs
# As this does not work for some of the 
# packages we want to build,
# we do not activate Holy Build Box environment.
# HBB is in this case only used for glibc compat, not static libs
# source /hbb_shlib/activate

# print all executed commands to the terminal
set -x

# set up environment
# ------------------

# X libraries are needed to make Tk, wget to download from sourceforge
yuminstall wget
# yuminstall openssl-devel

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

# source /hbb_exe/activate


# openssl
# -------
cd /build
wget --no-check-certificate  https://www.openssl.org/source/openssl-1.1.1l.tar.gz
tar xvzf openssl-1.1.1l.tar.gz
cd /build/openssl-1.1.1l
make clean || true
make distclean || true
./config -enable-static no-threads
# --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
make CFLAGS="-fPIC"
sudo make install
#sudo rm /usr/local/lib64/libssl.so* /usr/local/lib64/libcrypto.so*

# tcltls
# ------
prog=tcltls
finalprog=tls
version=1.7.22
target=$dirtcldir/exts/$prog$version
finaltarget=$dirtcldir/exts/$finalprog$version
cd /build/packages
wget -c https://core.tcl-lang.org/tcltls/uv/$prog-$version.tar.gz
tar xvzf $prog-$version.tar.gz
cd /build/packages/$prog-$version
make distclean
# edited to remove openssl test (which fails, but compilation works)
cp /io/build/configure.tcltls.edited configure
./configure --enable-static-ssl --with-openssl-dir=/usr/local/lib64/ --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib"
make
make install
rm -rf $finaltarget
mv $dirtcldir/lib/$prog$version $finaltarget
rm -f $finaltarget/init.tcl
cp -f /io/packages/$prog-$version-init.tcl $finaltarget/init.tcl
mkdir $finaltarget/lib
cp -f /io/packages/$prog-$version-lib_init.tcl $finaltarget/lib/init.tcl
rm -rf "$finaltarget/linux-$arch"
mkdir "$finaltarget/linux-$arch"
mv "$finaltarget/$prog.so" "$finaltarget/linux-$arch/libtls$version.so"

echo "Finished building package"
