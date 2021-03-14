#!/bin/sh
set -ex

export target="gcc-4.1.0-glibc-2.3.2"
export arch=i686
export tclversion=8.5.10

echo "Making $HOME/tcl/dirtcl$tclversion-$arch-$target"
# settings for cross-compilation
. $HOME/dev/dirtcl/build/cross-compat-$arch-$target.sh

# build dirtl
rm -f $HOME/tcl/dirtcl
rm -f $HOME/tcl/dirtcl-$arch-$target
rm -f $HOME/tcl/dirtcl-$arch
rm -rf $HOME/tcl/dirtcl$tclversion-$arch-$target
mkdir $HOME/tcl/dirtcl$tclversion-$arch-$target
cd $HOME/tcl
ln -s dirtcl$tclversion-$arch-$target dirtcl
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch-$target

cd $HOME/tcl/dirtcl$tclversion-$arch-$target
echo "make `pwd`"
# edit file, comment out: lines for making wish (lines after target wish@EXEEXT@:)
# cedit $HOME/tcl/tk8.5.10/unix/Makefile.in
$HOME/dev/dirtcl/makedirtcl.tcl --version $tclversion --disable-threads
