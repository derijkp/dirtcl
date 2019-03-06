#!/bin/sh
set -ex

export target="gcc-4.9.2-glibc-2.4"
export arch=x86_64
export tclversion=8.5.19

# settings for cross-compilation
. $HOME/dev/dirtcl/build/cross-compat-$arch-$target.sh

# build dirtl
rm -rf $HOME/tcl/dirtcl$tclversion-$arch-$target
mkdir $HOME/tcl/dirtcl$tclversion-$arch-$target

cd $HOME/tcl/dirtcl$tclversion-$arch-$target
echo "make `pwd`"
# edit file
# comment out lines for making wish (lines after target wish@EXEEXT@ or ${WISH_EXE})
# comment out lines for installing wish (@$(INSTALL_PROGRAM) ${WISH_EXE})
# cedit $HOME/tcl/tk$tclversion/unix/Makefile.in
$HOME/dev/dirtcl/makedirtcl.tcl --version $tclversion --host=$HOST

rm -f $HOME/tcl/dirtcl
rm -f $HOME/tcl/dirtcl-$arch
rm -f $HOME/tcl/dirtcl-$arch-$target
cd $HOME/tcl
ln -s dirtcl$tclversion-$arch-$target dirtcl
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch-$target
