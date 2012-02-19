export target="gcc-3.3.6-glibc-2.3.2"
export arch=i686
export tclversion=8.5.11

# settings for cross-compilation
. ~/dev/dirtcl/work/cross-compat-$arch-$target.sh

# build dirtl
rm ~/tcl/dirtcl
rm -rf ~/tcl/dirtcl$tclversion-$arch-$target
mkdir ~/tcl/dirtcl$tclversion-$arch-$target
cd ~/tcl
ln -s dirtcl$tclversion-$arch-$target dirtcl
ln -s dirtcl$tclversion-$arch-$target dirtcl-$arch-$target
cd ~/tcl/dirtcl
# edit file, comment out: lines for making wish (lines after target wish@EXEEXT@:)
cedit ~/tcl/tk8.5.11/unix/Makefile.in
~/dev/dirtcl/makedirtcl.tcl
