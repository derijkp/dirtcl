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
unset CXX
unset CPP
unset AR
unset LD
unset RANLIB

export CROSSTARGET="mingw32msvc"
export TARGETARCHITECTURE=i386

export TARGET="$TARGETARCHITECTURE-$CROSSTARGET"
export HOST="$TARGET"
export CROSSBASE="/opt/crosstool/$TARGET"
export CROSSNBASE="$CROSSBASE/$TARGET"
export CROSSBIN="$CROSSBASE/bin"
export CROSSNBIN="$CROSSNBASE/bin"
export BASE=~/extern/deps-$TARGETARCHITECTURE-$CROSSTARGET
export LDFLAGS="-L$CROSSNBASE/lib -L$CROSSBASE/lib/gcc/i386-mingw32msvc/3.4.1"
export CPPFLAGS="-I$CROSSNBASE/include -I$CROSSBASE/lib/gcc/i386-mingw32msvc/3.4.1/include"
export CFLAGS="-I$CROSSNBASE/include -I$CROSSBASE/lib/gcc/i386-mingw32msvc/3.4.1/include"
#export CC=${CROSS_COMPILE}gcc
#export CXX=${CROSS_COMPILE}g++
#export CPP=${CROSS_COMPILE}cpp
#export AR=${CROSS_COMPILE}ar
#export LD=${CROSS_COMPILE}ld
#export RANLIB=${CROSS_COMPILE}ranlib
export CROSS_COMPILE="$TARGET-"
export DISCIMAGE=$CROSSNBASE
if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$CROSSNBIN" ) ; then PATH=$CROSSNBIN:$PATH ; fi
if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$CROSSBIN" ) ; then PATH=$CROSSBIN:$PATH ; fi

DIRTCL=$HOME/tcl/dirtcl-${TARGETARCHITECTURE}-${CROSSTARGET}
