#!/bin/bash

tclversion=8.6.14
tclmtlsversion=1.1.0

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

# X libraries are needed to make Tk, wget to download from sourceforge
yuminstall wget
#yuminstall gcc-c++
#yuminstall centos-release-scl
#sudo yum upgrade -y
## sudo yum list all | grep devtoolset
yuminstall devtoolset-9
## use source instead of scl enable so it can run in a script
source /opt/rh/devtoolset-9/enable

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

# tclmtls
# -------

prog=tclmtls
finalprog=mtls
version=$tclmtlsversion
tlsdownload=tclmtls-$version
tlsdir=tclmtls-$version

yuminstall git

target=$dirtcldir/exts/$prog$version
finaltarget=$dirtcldir/exts/mtls-$tclmtlsversion
cd /build/packages
rm -rf tclmtls || true
git clone https://github.com/chpock/tclmtls.git
cd tclmtls
git checkout v1.1.0
git submodule update --init --recursive

mkdir build && cd build
../configure --prefix="$dirtcldir"
make
make install

rm -rf $finaltarget || true
# mkdir $finaltarget

mv $dirtcldir/lib/mtls$tclmtlsversion $finaltarget

rm -rf "$finaltarget/$arch"
mkdir "$finaltarget/$arch"
cp -al "$finaltarget/libmtls$tclmtlsversion.so" "$finaltarget/$arch/libmtls$tclmtlsversion.so"

rm -f $finaltarget/init.tcl
echo 'package require pkgtools
if {[package vsatisfies [package provide Tcl] 9.0-]} {
	load [file join $dir [pkgtools::architecture] libtcl9mtls1.1.0.so] [string totitle mtls]
} else {
	load [file join $dir [pkgtools::architecture] libmtls1.1.0.so] [string totitle mtls]
}
' > $finaltarget/init.tcl

echo 'package require pkgtools
if {[package vsatisfies [package provide Tcl] 9.0-]} {
    package ifneeded mtls 1.1.0 \
	[list load [file join $dir [pkgtools::architecture] libtcl9mtls1.1.0.so] [string totitle mtls]]
} else {
    package ifneeded mtls 1.1.0 \
	[list load [file join $dir [pkgtools::architecture] libmtls1.1.0.so] [string totitle mtls]]
}
' > $finaltarget/pkgIndex.tcl

echo "Finished building package $name in $finaltarget"
