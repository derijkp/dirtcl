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
#export LD_RUN_PATH=/usr/lib:/usr/local/lib

export CROSSTARGET="gcc-4.9.2-glibc-2.4"
export TARGETARCHITECTURE=i686

export TARGET="$TARGETARCHITECTURE-unknown-linux-gnu"
export HOST="$TARGET"
export CROSSBASE="/opt/crosstool/$CROSSTARGET/$TARGET"
export CROSSNBASE="$CROSSBASE/$TARGET"
export CROSSBIN="$CROSSBASE/bin"
export CROSSNBIN="$CROSSNBASE/bin"
export BASE=~/extern/deps-$TARGETARCHITECTURE-$CROSSTARGET
export LDFLAGS="-L$CROSSNBASE/lib"
export CPPFLAGS="-I$CROSSNBASE/include"
export CFLAGS="-I$CROSSNBASE/include"
#export CC=${CROSS_COMPILE}gcc
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

DIRTCL=$HOME/tcl/dirtcl-${TARGETARCHITECTURE}-${CROSSTARGET}
