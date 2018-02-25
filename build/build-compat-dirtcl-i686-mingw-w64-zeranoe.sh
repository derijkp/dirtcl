#!/bin/sh
set -ex

export target="mingw32"
export arch=i686-w64
export tclversion=8.5.18

# settings for cross-compilation
. cross-compat-i686-mingw-w64.sh

# build dirtl
rm -rf $DIRTCL
mkdir $DIRTCL
cd $HOME/tcl

cd $DIRTCL
echo "make `pwd`"
$HOME/dev/dirtcl/makedirtcl.tcl --version $tclversion --enable-threads crosswin
