#!/bin/bash

tclversion=8.5.19

# This script builds dirtcl using the Holy build box environment
# options:
# -a|-arch|--arch: 64, x86_64 or linux-x86_64 for 64 bit Linux build (default); ix86, 32 or linux-ix86 for 32 bits Linux build; win, windows-x86_64 or mingw-w64 for Windows 64 bit build
# -b|-bits|--bits: select 32 or 64 bits Linux build (default 64 = same as -arch x86_64)
# -d|-builddir|--builddir: top directory to build in (default ~/build/bin-$arch)
# -v|-version|--version: tcl version (default $tclversion)

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
# Tk does not compile with these settings (X)
# only use HBB for glibc compat, not static libs
# source /hbb_shlib/activate

# print all executed commands to the terminal
set -x

# set up environment
# ------------------

if [[ $arch =~ "linux" ]]; then
	yuminstall devtoolset-9
	## use source instead of scl enable so it can run in a script
	## scl enable devtoolset-9 bash
	source /opt/rh/devtoolset-9/enable

	# X libraries are needed to make Tk
	yuminstall libX11-devel

	os="Linux"
else
	os="Windows"
fi

# makedirtcl needs tcl to run
yuminstall tcl
yuminstall wget

# Build
# -----
cd /build

# get tcl and tk
cd /build
if [ ! -f tcl$tclversion-src.tar.gz ] ; then
    wget -c --tries=40 --max-redirect=40 http://prdownloads.sourceforge.net/tcl/tcl$tclversion-src.tar.gz
fi
if [ ! -f tk$tclversion-src.tar.gz ] ; then
    wget -c --tries=40 --max-redirect=40 http://prdownloads.sourceforge.net/tcl/tk$tclversion-src.tar.gz
fi
tar xvzf tcl$tclversion-src.tar.gz
tar xvzf tk$tclversion-src.tar.gz

# Run makedirtcl
rm -rf /build/dirtcl$tclversion-$arch
mkdir /build/dirtcl$tclversion-$arch
cd /build/dirtcl$tclversion-$arch
if [ "$os" == "Windows" ] ; then
	dirtcl_os='crosswin'
else
	dirtcl_os="$os"
fi
/io/makedirtcl.tcl --version $tclversion --os $dirtcl_os

# dirtcl tclsh in tcl source does not work in location, hack to solve
cd /build/tcl$tclversion/unix
mv tclsh tclsh.ori || true
ln -sf ../../dirtcl$tclversion-$arch/tclsh$tclshortversion tclsh || true

# make links
cd /build
ln -sf dirtcl$tclversion-$arch dirtcl
ln -sf dirtcl$tclversion-$arch dirtcl-$arch

echo "Finished building dirtcl"
