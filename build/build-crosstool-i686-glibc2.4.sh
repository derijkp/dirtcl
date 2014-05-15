#!/bin/sh

# trying crosstools-ng 
#cd ~/extern
#export ctversion=1.5.3
#wget -c http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$ctversion.tar.bz2
#tar xvjf crosstool-ng-$ctversion.tar.bz2
#cd crosstool-ng-$ctversion
#./configure --prefix=$HOME/apps/crosstool-ng-$ctversion
#make
#make install
#
#mkdir ~/extern/build-crosstool-ng
#cd ~/extern/build-crosstool-ng
#rm -rf ~/extern/build-crosstool-ng/*
#PATH="${PATH}:$HOME/apps/crosstool-ng-$ctversion/bin" ct-ng x86_64-unknown-linux-gnu
#PATH="${PATH}:$HOME/apps/crosstool-ng-$ctversion/bin" ct-ng menuconfig

# to download and install crosstool
# cd ~/extern
# wget -c http://kegel.com/crosstool/crosstool-0.43.tar.gz
# tar -xzvf crosstool-0.43.tar.gz
#cd ~/extern/crosstool-0.43
# adapt patch for gcc 4.*
#cp ~/dev/dirtcl/work/glibc-2.3.3-allow-gcc-4.0-configure.patch patches/glibc-2.3.2

## install crosstool with glibc2.4 support take 2
#wget -c http://kegel.com/crosstool/crosstool-0.42.tar.gz
#tar -xzvf crosstool-0.42.tar.gz
#cd ~/extern/crosstool-0.42
#patch < ~/dev/dirtcl/work/crosstool-0.42-mg2.patch

## install crosstool with glibc2.4 support
#cd ~/extern
#svn checkout http://crosstool.googlecode.com/svn/trunk/ crosstool-read-only
#mv crosstool-read-only/src ~/extern/crosstool-svn
#rm -rf crosstool-read-only
#cd ~/extern/crosstool-svn

#cd ~/extern/crosstool-0.43
#cd ~/extern/crosstool-0.42
cd ~/extern/crosstool-svn
# rm -rf ~/extern/crosstool-svn/build

unset CFLAGS
#export CFLAGS=" -Wno-unused-but-set-variable"
#export CPPFLAGS=" -Wno-unused-but-set-variable"
unset LD_LIBRARY_PATH
# glibc 2.3.2 will not compile using recent gcc, add a link to an older one in bin, and put in path
# glibc 2.3.2 will not compile using recent gcc, put older one in path
# glibc 2.3.2 will not compile using recent make, put older one in path
#PATH=/home/peter/apps/gcc-3.4.6/bin/:/home/peter/apps/make3.81/bin:$PATH 
#PATH=/opt/crosstool/binutils-2.16.1:$PATH

# for static builds, uncomment the following
#BINUTILS_EXTRA_CONFIG="LDFLAGS=-all-static"
#GCC_EXTRA_CONFIG="LDFLAGS=-static"

# from demo-i686
set -ex
export TARBALLS_DIR=$HOME/downloads
export RESULT_TOP=/opt/crosstool
export GCC_LANGUAGES="c,c++"

# i686.dat
export KERNELCONFIG=`pwd`/i686.config
export TARGET=i686-unknown-linux-gnu
export TARGET_CFLAGS="-O"
export GCC_EXTRA_CONFIG="$GLIBC_EXTRA_CONFIG --with-arch=pentium3 --with-tune=pentium4"

## gcc-4.1.2-glibc-2.4.dat
#export BINUTILS_DIR=binutils-2.16.1
#export GCC_CORE_DIR=gcc-4.1.2
#export GCC_DIR=gcc-4.1.2
#export GLIBC_DIR=glibc-2.4
#export LINUX_DIR=linux-2.6.15
#export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
#export GDB_DIR=gdb-6.5a
#export GLIBC_EXTRA_CONFIG="$GLIBC_EXTRA_CONFIG --with-tls --with-__thread  --enable-kernel=2.4.18"
#export GLIBC_ADDON_OPTIONS="=nptl"

# gcc-4.2.0-glibc-2.4-nptl.dat
#export BINUTILS_DIR=binutils-2.16.1
export BINUTILS_DIR=binutils-2.17
export BINUTILS_EXTRA_CONFIG="$BINUTILS_EXTRA_CONFIG --disable-werror"
export GCC_CORE_DIR=gcc-4.2.0
export GCC_DIR=gcc-4.2.0
export GLIBC_DIR=glibc-2.4
export LINUX_DIR=linux-2.6.15
export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
export GDB_DIR=gdb-6.5a
export GLIBC_EXTRA_CONFIG="$GLIBC_EXTRA_CONFIG --with-tls --with-__thread  --enable-kernel=2.4.18"
export GLIBC_ADDON_OPTIONS="=nptl"

# run crosstool
sh all.sh --notest
