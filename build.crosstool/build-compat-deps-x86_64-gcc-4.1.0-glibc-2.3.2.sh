#!/bin/bash
set -ex

target="gcc-4.1.0-glibc-2.3.2"
arch=x86_64
base=~/extern/deps-$arch-$target
xversion=X11R7.0

# this keeps track of which parts have been finished, use following to restart clean
# rm -rf $base
mkdir -p $base || true
mkdir -p $base/../downloads || true

cd $base
# settings for cross-compilation
. ~/dev/dirtcl/build/cross-compat-$arch-$target.sh


function compile {
    path=$1
    file=${path##*/}
    cd $base
    echo "----------------------------------------------------------------------------------------"
    echo "---------- compiling $file ----------"
    echo "----------------------------------------------------------------------------------------" >> log
    echo "---------- compiling $file ----------" >> log
    test=""
    test=`grep "make finished" ${file%.tar.*}/log` || true
    if [ "$test" != "" ]; then
        echo "-- Skipping $file"
    else
        echo "-- Unpacking $file"
        if [ "${file##*.}" = "gz" ]; then
            tar xzf $path
        else
            tar xjf $path
        fi
        file=${file##*/}
        cd $base/${file%.tar.*}
        make distclean || true
        echo "-- Configuring $file"
        if [[ "${file}" == "openssl-0.9.8h.tar.gz" ]]; then
            PATH=$CROSSBIN:$PATH ./Configure linux-elf no-asm shared --prefix=$CROSSNBASE
            # PATH=$CROSSBIN:$PATH make install >> log
        elif [[ "${file}" == "openssl-1.0.1c.tar.gz" ]]; then
            PATH=$CROSSBIN:$PATH ./Configure linux-elf no-asm shared --prefix=$CROSSNBASE
            PATH=$CROSSBIN:$PATH make install >> log
            PATH=$CROSSBIN:$PATH make install >> log
        elif  [ "${file}" == "libX11-X11R7.1-1.0.1.tar.bz2" ]; then
            # cp ../libX11-1.2/src/util/makekeys.c src/util/makekeys.c
            ./configure --prefix=$CROSSNBASE >> log
        elif  [ "${file}" == "libxml2-2.7.8.tar.gz" ]; then
            ./configure --prefix=$CROSSNBASE --without-python >> log
        elif  [[ "${file}" == "xcb-proto-1.7.tar.bz2" ]]; then
            ./configure --prefix=$CROSSNBASE --without-python >> log
        elif  [ "${file}" == "fontconfig-2.9.0.tar.gz" ]; then
            ./configure --prefix=$CROSSNBASE >> log
            cp Makefile Makefile.ori
            sed -e 's/fc-cache\//#fc-cache\//' Makefile.ori > Makefile
        elif  [ "${file}" == "libX11-1.2.tar.bz2" ]; then
            echo "only needed for makekeys.c"
        elif  [ "${file}" == "libgcrypt-1.4.6.tar.bz2" ]; then
            ./configure --disable-aesni-support --disable-asm --enable-shared --prefix=$CROSSNBASE >> log
        elif  [ "${file}" == "bison-2.7.tar.gz" ]; then
            PATH=$PATH:$CROSSNBIN ./configure --prefix=$CROSSNBASE >> log
        else
            ./configure --prefix=$CROSSNBASE >> log
        fi
        echo "-- Compiling $file"
        if [[ "${file}" == "openssl-1.0.1c.tar.gz" ]]; then
            echo 'nothing'
        else
            make install >> log
        fi
        echo "make finished" >> log
        echo "make finished"
    fi
}

function download {
    url=$1
    file=${url##*/}
    cd $base/../downloads
    if [ ! -f "$file" ]; then
        wget -c --retr-symlinks $url
    fi
}

#http://cairographics.org/releases/pixman-0.24.4.tar.gz 
#ftp://xmlsoft.org/libxslt/libxslt-1.1.26.tar.gz 

#ftp://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz \
##ftp://ftp.gnupg.org/gcrypt/libksba/libksba-1.2.0.tar.bz2 \
##ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.0.3.tar.bz2 \
#ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.18.tar.bz2 \
#

for url in \
http://ftp.easynet.be/ftp/gnu/libtool/libtool-2.4.tar.gz \
http://zlib.net/zlib-1.2.6.tar.gz \
http://sourceforge.net/projects/libpng/files/libpng15/older-releases/1.5.2/libpng-1.5.2.tar.gz \
http://sourceforge.net/projects/expat/files/expat/2.0.1/expat-2.0.1.tar.gz \
http://www.openssl.org/source/openssl-1.0.1c.tar.gz \
ftp://xmlsoft.org/libxml2/libxml2-2.7.8.tar.gz \
ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.20.tar.gz \
http://www.sqlite.org/sqlite-autoconf-3071000.tar.gz \
http://xcb.freedesktop.org/dist/libpthread-stubs-0.3.tar.bz2 \
http://xorg.freedesktop.org/archive/individual/lib/libpciaccess-0.12.902.tar.gz \
http://dri.freedesktop.org/libdrm/libdrm-2.3.1.tar.gz \
http://pkgconfig.freedesktop.org/releases/pkg-config-0.24.tar.gz \
http://xcb.freedesktop.org/dist/xcb-proto-1.7.tar.bz2 \
http://sourceforge.net/projects/freetype/files/freetype2/2.4.9/freetype-2.4.9.tar.gz \
http://freedesktop.org/software/fontconfig/release/fontconfig-2.9.0.tar.gz \
ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.10.tar.bz2 \
ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.4.6.tar.bz2 \
ftp://xmlsoft.org/libxslt/libxslt-1.1.26.tar.gz \
http://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.gz \
http://ftp.gnu.org/gnu/bison/bison-2.7.tar.gz
do
    file=${url##*/}
    echo "----------------------------------------------------------------------------------------"
    echo "---------- $file ----------"
    echo "----------------------------------------------------------------------------------------" >> log
    echo "---------- $file ----------" >> log
    download $url
    cd $base
    file=${url##*/}
    compile "../downloads/$file"
done

#mkdir -p $base/../downloads/X11R7.2
#cd $base/../downloads/X11R7.2
#if [ -f DOWNLOAD_FINISHED ] ; then
#	echo "DOWNLOAD_FINISHED exists: X11R7.2 already downloaded, skipping"
#else
#	echo "Downloading X11R7.2"
#	wget -c --retr-symlinks ftp://ftp.x.org/pub/X11R7.2/src/everything/*.bz2
#	wget -c http://www.x.org/releases/individual/data/xkeyboard-config/xkeyboard-config-2.4.tar.bz2
#	wget -c http://xorg.freedesktop.org/releases/individual/lib/libX11-1.2.tar.bz2
#	wget -c http://xcb.freedesktop.org/dist/xcb-proto-1.7.tar.bz2
#	wget -c http://xcb.freedesktop.org/dist/libxcb-1.8.tar.bz2
#	wget -c http://xcb.freedesktop.org/dist/xcb-util-0.3.8.tar.bz2
#	wget -c http://xcb.freedesktop.org/dist/xcb-util-keysyms-0.3.8.tar.bz2
#	wget -c http://xcb.freedesktop.org/dist/libpthread-stubs-0.3.tar.bz2
#	wget -c http://cgit.freedesktop.org/xcb/pthread-stubs/snapshot/pthread-stubs-0.3.tar.gz
#	echo "all downloaded" > DOWNLOAD_FINISHED
#fi

mkdir -p $base/../downloads/$xversion
cd $base/../downloads/$xversion
#if [ -f DOWNLOAD_FINISHED ] ; then
#	echo "DOWNLOAD_FINISHED exists: X11R7.1 already downloaded, skipping"
#else
#	echo "Downloading X11R7.1"
#	wget -c --retr-symlinks ftp://ftp.x.org/pub/X11R7.6/src/everything/*.bz2
#	wget -c http://xcb.freedesktop.org/dist/xcb-proto-1.5.tar.bz2
#	wget -c http://xcb.freedesktop.org/dist/libxcb-1.5.tar.bz2
#
#	echo "all downloaded" > DOWNLOAD_FINISHED
#fi

#cd $base/../downloads/X11R7.1
#for file in \
#xproto-*.tar.bz2 \
#xf86driproto-*.tar.bz2 \
#glproto-*.tar.bz2 \
#libXau-*.tar.bz2 \
#xtrans-*.tar.bz2 \
#xextproto-*.tar.bz2 \
#kbproto-*.tar.bz2 \
#inputproto-*.tar.bz2 \
#libXdmcp-*.tar.bz2 \
#xf86bigfontproto-*.tar.bz2 \
#bigreqsproto-*.tar.bz2 \
#xcmiscproto-*.tar.bz2 \
#xproto-*.tar.bz2 \
#randrproto-*.tar.bz2 \
#renderproto-*.tar.bz2 \
#fixesproto-*.tar.bz2 \
#damageproto-*.tar.bz2 \
#xf86vidmodeproto-*.tar.bz2 \
#scrnsaverproto-*.tar.bz2 \
#fontsproto-*.tar.bz2 \
#xf86dgaproto-*.tar.bz2 \
#videoproto-*.tar.bz2 \
#compositeproto-*.tar.bz2 \
#recordproto-*.tar.bz2 \
#resourceproto-*.tar.bz2 \
#xineramaproto-*.tar.bz2 \
#libfontenc-*.tar.bz2 \
#xtrans-*.tar.bz2 \
#libpthread-stubs-*.tar.gz \
#xcb-proto-*.tar.bz2 \
#libxcb-*.tar.bz2 \
#libX11-*.tar.bz2 \
#libxkbfile-*.tar.bz2 \
#libXext-*.tar.bz2 \
#libXfont-*.tar.bz2 \
#libXi-*.tar.bz2 \

#xorg-server-*.tar.bz2 \
#xf86-input-keyboard-*.tar.bz2 \
#xfontsel-*.tar.bz2 \
#xf86-input-keyboard-*.tar.bz2 \
#xkeyboard-config-*.tar.bz2 \
#libXaw-*.tar.bz2 \
#libXext-*.tar.bz2
#

xurl=ftp://ftp.x.org/pub/$xversion/src/everything
mkdir $base/../downloads/$xversion || true
cd $base/../downloads/$xversion
if [ ! -f libxcb-1.8.tar.bz2 ]; then
	wget -c http://xcb.freedesktop.org/dist/libxcb-1.8.tar.bz2
fi

for file in \
xproto-*.tar.bz2 \
libXau-*.tar.bz2 \
xtrans-*.tar.bz2 \
xextproto-*.tar.bz2 \
kbproto-*.tar.bz2 \
inputproto-*.tar.bz2 \
libXdmcp-*.tar.bz2 \
xf86bigfontproto-*.tar.bz2 \
bigreqsproto-*.tar.bz2 \
xcmiscproto-*.tar.bz2 \
util-macros-*.tar.bz2 \
libxcb-1.8.tar.bz2 \
xproto-*.tar.bz2 \
libX11-*.tar.bz2 \
renderproto-*.tar.bz2 \
libXrender-*.tar.bz2 \
libXft-*.tar.bz2
do
    echo "----------------------------------------------------------------------------------------"
    echo "---------- $file ----------"
    echo "----------------------------------------------------------------------------------------" >> log
    echo "---------- $file ----------" >> log
    cd $base/../downloads/$xversion
    if [[ ! -f `ls $file` ]]; then
        wget -c --retr-symlinks $xurl/$file
    fi
    cd $base
    compile $base/../downloads/$xversion/$file
done

echo "Finished" >> log
echo "Finished"
