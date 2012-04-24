#!/bin/sh

# to download and install crosstool
# cd ~/extern
# wget -c http://kegel.com/crosstool/crosstool-0.43.tar.gz
# tar -xzvf crosstool-0.43.tar.gz

cd ~/extern/crosstool-0.43
# adapt patch for gcc 4.*
#cp ~/dev/dirtcl/work/glibc-2.3.3-allow-gcc-4.0-configure.patch patches/glibc-2.3.2

# glibc 2.3.2 will not compile using recent gcc, add a link to an older one in bin, and put in path
# glibc 2.3.2 will not compile using recent gcc, put older one in path
# glibc 2.3.2 will not compile using recent make, put older one in path
unset CFLAGS
unset LD_LIBRARY_PATH
#PATH=/home/peter/apps/gcc-3.4.6/bin/:/home/peter/apps/make3.81/bin:$PATH 

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

# gcc-3.3.6-glibc-2.3.2.dat
#export BINUTILS_DIR=binutils-2.15
#export GCC_DIR=gcc-3.3.6
#export GLIBC_DIR=glibc-2.3.2
#export GLIBCTHREADS_FILENAME=glibc-linuxthreads-2.3.2
#export LINUX_DIR=linux-2.4.26
#export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0

## gcc-4.1.0-glibc-2.3.2.dat
export BINUTILS_DIR=binutils-2.16.1
export GCC_CORE_DIR=gcc-3.3.6
export GCC_DIR=gcc-4.1.0
export GLIBC_DIR=glibc-2.3.2
export LINUX_DIR=linux-2.6.15
export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
export GLIBCTHREADS_FILENAME=glibc-linuxthreads-2.3.2
export GDB_DIR=gdb-6.5a

# gcc-4.1.1-glibc-2.3.6.dat
#export BINUTILS_DIR=binutils-2.16.1
#export GCC_CORE_DIR=gcc-3.3.6
#export GCC_DIR=gcc-4.1.1
#export GLIBC_DIR=glibc-2.3.6
#export LINUX_DIR=linux-2.6.15.4
#export LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
#export GLIBCTHREADS_FILENAME=glibc-linuxthreads-2.3.6
#export GDB_DIR=gdb-6.5a

# run crosstool
sh all.sh --notest
