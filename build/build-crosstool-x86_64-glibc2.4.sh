#!/bin/sh
set -ex

cd ~/extern/crosstool-svn
# rm -rf ~/extern/crosstool-svn/build

unset CFLAGS
#export CFLAGS=" -Wno-unused-but-set-variable"
#export CPPFLAGS=" -Wno-unused-but-set-variable"
unset LD_LIBRARY_PATH
#PATH=/home/peter/apps/gcc-3.4.6/bin/:/home/peter/apps/make3.81/bin:$PATH 
#PATH=/opt/crosstool/binutils-2.16.1:$PATH

# for static builds, uncomment the following
#BINUTILS_EXTRA_CONFIG="LDFLAGS=-all-static"
#GCC_EXTRA_CONFIG="LDFLAGS=-static"

# from demo-x86_64
export TARBALLS_DIR=$HOME/downloads
export RESULT_TOP=/opt/crosstool
export GCC_LANGUAGES="c,c++"

# x86_64.dat
export TARGET=x86_64-unknown-linux-gnu
export TARGET_CFLAGS="-O"
export GCC_EXTRA_CONFIG="--disable-multilib"
export USE_SYSROOT=1
export KERNELCONFIG=`pwd`/x86_64.config

# gcc-4.2.0-glibc-2.4-nptl.dat
export BINUTILS_DIR=binutils-2.16.1
export BINUTILS_EXTRA_CONFIG="$BINUTILS_EXTRA_CONFIG --disable-werror"
export GCC_CORE_DIR=gcc-4.2.0
export GCC_DIR=gcc-4.2.0
export GLIBC_DIR=glibc-2.4
export LINUX_DIR=linux-2.6.15
export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
export GDB_DIR=gdb-6.5a
export GLIBC_EXTRA_CONFIG="$GLIBC_EXTRA_CONFIG --with-tls --with-__thread  --enable-kernel=2.4.18"
export GLIBC_ADDON_OPTIONS="=nptl"

## gcc-4.9.1-glibc-2.4-nptl.dat
#export BINUTILS_DIR=binutils-2.24
#export BINUTILS_EXTRA_CONFIG="$BINUTILS_EXTRA_CONFIG --disable-werror"
#export GCC_CORE_DIR=gcc-4.9.1
#export GCC_DIR=gcc-4.9.1
#export GLIBC_DIR=glibc-2.4
#export LINUX_DIR=linux-2.6.15
#export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
#export GDB_DIR=gdb-6.5a
##export GLIBC_EXTRA_CONFIG="$GLIBC_EXTRA_CONFIG --with-tls --with-__thread  --enable-kernel=2.4.18"
#export GLIBC_EXTRA_CONFIG="$GLIBC_EXTRA_CONFIG --with-__thread  --enable-kernel=2.4.18"
#export GLIBC_ADDON_OPTIONS="=nptl"
##export GMP_DIR=gmp-6.0.0a
##export MPFR_DIR=mpfr-3.1.2
##export MPC_DIR=mpc-1.0.2
#export GMP_DIR=gmp-4.1.4
#export MPFR_DIR=mpfr-2.3.2
#export MPC_DIR=mpc-1.0.2
#export CT_CC_EXTRA_CONFIG="--disable-libstdcxx-pch"

export PREFIX=$RESULT_TOP/$TOOLCOMBO/$TARGET

export TOOLCOMBO=$GCC_DIR-$GLIBC_DIR
export BUILD_DIR=$HOME/extern/crosstoolbuild-$TARGET-$TOOLCOMBO

echo TOOLCOMBO=$TOOLCOMBO
echo PREFIX=$PREFIX
echo BUILD_DIR=$BUILD_DIR
echo SRC_DIR=$SRC_DIR
echo TARBALLS_DIR=$TARBALLS_DIR
echo TOP_DIR=$TOP_DIR

# run crosstool
sh all.sh --notest
