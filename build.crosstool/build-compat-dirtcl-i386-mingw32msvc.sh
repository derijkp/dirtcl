#!/bin/sh
set -ex

export target="mingw32"
export arch=i686-w64
export tclversion=8.5.18

# settings for cross-compilation
. $HOME/dev/dirtcl/build/cross-compat-$arch-$target.sh

# build dirtl
rm -f $HOME/tcl/dirtcl-$arch-$target
rm -f $HOME/tcl/dirtcl-$target
rm -rf $HOME/tcl/dirtcl$tclversion-$arch-$target
mkdir $HOME/tcl/dirtcl$tclversion-$arch-$target
cd $HOME/tcl
ln -s dirtcl$tclversion-$arch-$target dirtcl-$target
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch-$target

cd $HOME/tcl/dirtcl$tclversion-$arch-$target
echo "make `pwd`"
$HOME/dev/dirtcl/makedirtcl.tcl --version $tclversion --enable-threads crosswin



#!/bin/sh
set -ex

export target="w64-mingw32"
export arch=i686
export tclversion=8.5.18

# settings for cross-compilation
. $HOME/dev/dirtcl/build/cross-compat-$arch-$target.sh

# build dirtl
rm -f $HOME/tcl/dirtcl-$arch-$target
rm -f $HOME/tcl/dirtcl-$target
rm -rf $HOME/tcl/dirtcl$tclversion-$arch-$target
mkdir $HOME/tcl/dirtcl$tclversion-$arch-$target
cd $HOME/tcl
ln -s dirtcl$tclversion-$arch-$target dirtcl-$target
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch-$target

cd $HOME/tcl/dirtcl$tclversion-$arch-$target
echo "make `pwd`"
$HOME/dev/dirtcl/makedirtcl.tcl --version $tclversion --enable-threads crosswin

