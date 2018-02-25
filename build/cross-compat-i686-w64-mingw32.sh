# install required tools and libs with
# sudo apt-get install mingw-w64 gfortran-mingw-w64 binutils-mingw-w64 gcc-mingw32 mingw-w64-tools
unset CROSS_COMPILE
unset DISCIMAGE
unset CROSSTARGET
unset TARGET
unset CROSSBASE
unset CROSSNBASE
unset CROSSBIN
unset CROSSNBIN
unset BASE
unset LDFLAGS
unset CPPFLAGS
unset CFLAGS
unset CC
unset AR
unset LD
unset RANLIB
unset EXEEXT
#export LD_RUN_PATH=/usr/lib:/usr/local/lib

export CROSSTARGET="w64-mingw32"
export TARGETARCHITECTURE=i686

export TARGET="$TARGETARCHITECTURE-$CROSSTARGET"
export HOST="$TARGET"
export CROSSBASE="/opt/crosstool/mingw-w64-zeranoe/mingw-w64-i686"
export CROSSNBASE="$CROSSBASE/$TARGET"
export CROSSBIN="$CROSSBASE/bin"
export CROSSNBIN="$CROSSNBASE/bin"
export BASE=~/extern/deps-$TARGETARCHITECTURE-$CROSSTARGET
export LDFLAGS="-L$CROSSNBASE/lib"
export CPPFLAGS="-I$CROSSNBASE/include"
export CFLAGS="-I$CROSSNBASE/include"
export EXEEXT=.exe
#export CC=${CROSS_COMPILE}gcc
#export CXX=${CROSS_COMPILE}g++
#export CPP=${CROSS_COMPILE}cpp
#export AR=${CROSS_COMPILE}ar
#export LD=${CROSS_COMPILE}ld
#export RANLIB=${CROSS_COMPILE}ranlib
export CROSS_COMPILE="$TARGET-"
export DISCIMAGE=$CROSSNBASE
export PKG_CONFIG_PATH=$CROSSNBASE/lib/pkgconfig:$CROSSNBASE/share/pkgconfig
# export ACLOCAL="aclocal -I $CROSSNBASE/share/aclocal"
export PREFIX=$CROSSNBASE
# if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$CROSSNBIN" ) ; then PATH=$CROSSNBIN:$PATH ; fi
if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$CROSSBIN" ) ; then PATH=$CROSSBIN:$PATH ; fi

export DIRTCL=$HOME/tcl/dirtcl-i686-mingw-w64-zeranoe
