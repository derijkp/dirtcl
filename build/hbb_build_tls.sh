#!/bin/bash

tclversion=9.0.3
opensslversion=3.3.1
opensslversion=3.5.2
tcltlsversion=2.0b1

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
source "${dir}/start_hbb3.sh"

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
yuminstall devtoolset-11
## use source instead of scl enable so it can run in a script
source /opt/rh/devtoolset-11/enable

sudo yum install -y openssl-devel pkg-config

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

# openssl
# -------
yuminstall perl-IPC-Cmd
cd /build
#download https://www.openssl.org/source/openssl-1.1.1b.tar.gz
#cd /build/openssl-1.1.1b
wget -c --no-check-certificate https://www.openssl.org/source/openssl-$opensslversion.tar.gz
tar xvzf openssl-$opensslversion.tar.gz
cd /build/openssl-$opensslversion
make clean || true
make distclean || true
# ./config -enable-static
./config -enable-static --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
make CFLAGS="-fPIC"
sudo make install
sudo ldconfig
# Update the system-wide OpenSSL configurations
sudo tee /etc/profile.d/openssl.sh<<EOF
export PATH=/usr/local/openssl/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/openssl/lib:/usr/local/openssl/lib64:\$LD_LIBRARY_PATH
EOF

source /etc/profile.d/openssl.sh

# tcltls
# ------


prog=tcltls
finalprog=tls
version=$tcltlsversion
tlsdownload=tcltls-$version
# tlsdownload=tcltls-$version-src
tlsdir=tcltls-$version

target=$dirtcldir/exts/$prog$version
finaltarget=$dirtcldir/exts/$finalprog-$version
cd /build/packages
wget -c https://chiselapp.com/user/bohagan/repository/TCLTLS/uv/tcltls-$tcltlsversion.tar.gz
# wget -c https://core.tcl-lang.org/tcltls/uv/$tlsdownload.tar.gz
rm -rf $tlsdownload || true
tar xvzf $tlsdownload.tar.gz

cd /build/packages/$tlsdir
make distclean || true

    ./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --enable-static-ssl



# edited to remove openssl test (which fails, but compilation works)
# cp /io/build/configure.tcltls.edited configure
mv configure configure.ori || true
grep -v 'Unable to compile a basic program using OpenSSL' configure.ori > configure
chmod u+x configure

#  --with-openssl-dir=/usr/local/lib64
    ./configure --prefix="$dirtcldir" --with-tcl="$dirtcldir/lib" --enable-static-ssl --enable-64bit \
        --with-openssl-dir=/usr/local/openssl --with-openssl-libdir=/usr/local/openssl/lib64

# hack to make it compile (added -DOPENSSL_NO_DH to CFLAGS), no longer needed (with newer openssl?)
# cp /io/build/patches/tcltls-1.7.22_Makefile Makefile

make

make install

rm -rf $finaltarget
mv $dirtcldir/lib/$finalprog$version $finaltarget

rm -f $finaltarget/init.tcl
echo '
if {[package vsatisfies [package provide Tcl] 9.0-]} {
        # Load library
        load [file join $dir libtcl9tls2.0b1.so] [string totitle tls]
        # Source init file
        set initScript [file join $dir tls.tcl]
        if {[file exists $initScript]} {
            source -encoding utf-8 $initScript
        }
} else {
    if {![package vsatisfies [package provide Tcl] 8.5]} {return}
        # Load library
        if {[string tolower [file extension libtls2.0b1.so]] in [list .dll .dylib .so]} {
            # Load dynamic library
            load [file join $dir libtls2.0b1.so] [string totitle tls]
        } else {
            # Static library
            load {} [string totitle tls]
        }
        # Source init file
        set initScript [file join $dir tls.tcl]
        if {[file exists $initScript]} {
            source -encoding utf-8 $initScript
        }
}
' > $finaltarget/init.tcl

echo "Finished building package $name in $builddir/dirtcl$tclversion-$arch/exts/$finalprog$version"
