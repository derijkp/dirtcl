#!/bin/bash
set -ex

PS1="deps-i686 \W % "
target="gcc-4.9.2-glibc-2.4"
arch=i686
base=~/extern/deps-$arch-$target
xversion=X11R7.0

# some programs have to be present
# sudo apt-get install xsltproc

# settings for cross-compilation
. /opt/crosstool/cross-compat-$arch-$target.sh

. ~/dev/dirtcl/build/buildtools.sh

# this keeps track of which parts have been finished, use following to restart clean
# rm -rf $base/*
mkdir -p $base || true
mkdir -p $base/../downloads || true

cd $base

#http://cairographics.org/releases/pixman-0.24.4.tar.gz 

cd $base
download_ccompile http://ftp.easynet.be/ftp/gnu/libtool/libtool-2.4.tar.gz
download_compile http://zlib.net/zlib-1.2.8.tar.gz
download_ccompile http://sourceforge.net/projects/libpng/files/libpng15/older-releases/1.5.2/libpng-1.5.2.tar.gz
download_ccompile http://sourceforge.net/projects/expat/files/expat/2.0.1/expat-2.0.1.tar.gz
# download_compile http://www.openssl.org/source/openssl-1.0.1j.tar.gz
download_compile http://www.openssl.org/source/openssl-1.0.2a.tar.gz
download_ccompile ftp://xmlsoft.org/libxml2/libxml2-2.7.8.tar.gz
download_ccompile ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz
download_compile http://www.sqlite.org/2014/sqlite-autoconf-3080704.tar.gz
download_compile http://xcb.freedesktop.org/dist/libpthread-stubs-0.3.tar.bz2
download_compile http://xorg.freedesktop.org/archive/individual/lib/libpciaccess-0.12.902.tar.gz
download_compile http://dri.freedesktop.org/libdrm/libdrm-2.3.1.tar.gz
download_compile http://pkgconfig.freedesktop.org/releases/pkg-config-0.24.tar.gz
download_compile http://xcb.freedesktop.org/dist/xcb-proto-1.7.tar.bz2
#
# freetype2 hack: create the "internal" directory before compiling, 
# so the build process can delete it, iso giving an error
#download_compile http://sourceforge.net/projects/freetype/files/freetype2/2.4.9/freetype-2.4.9.tar.gz || true
download http://sourceforge.net/projects/freetype/files/freetype2/2.4.9/freetype-2.4.9.tar.gz || true
mkdir -p $CROSSNBASE/include/freetype2/freetype/internal || true
compile http://sourceforge.net/projects/freetype/files/freetype2/2.4.9/freetype-2.4.9.tar.gz
#
download_compile http://freedesktop.org/software/fontconfig/release/fontconfig-2.9.0.tar.gz
#
# and another hack for libgpg-error
download ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.10.tar.bz2
echo "dummy" > libgpg-error-1.10/src/extra-h.in
compile ../downloads/libgpg-error-1.10.tar.bz2
#
download_compile ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.4.6.tar.bz2
download_compile ftp://xmlsoft.org/libxslt/libxslt-1.1.26.tar.gz
download_compile http://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.gz
download_compile http://ftp.gnu.org/gnu/bison/bison-2.7.tar.gz
download_ccompile http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz
download_ccompile http://www.thrysoee.dk/editline/libedit-20121213-3.0.tar.gz
download_ccompile http://xcb.freedesktop.org/dist/libpthread-stubs-0.3.tar.gz
#download_ccompile ftp://ftp.gnu.org/gnu/gmp/gmp-5.1.1.tar.bz2
#download_ccompile http://ftp.gnu.org/gnu/nettle/nettle-2.6.tar.gz

xurl=http://ftp.x.org/pub/$xversion/src/everything
#mkdir -p $base/../downloads/$xversion || true
#cd $base/../downloads/$xversion
#wget -c $xurl/*

cd $base
download_ccompile $xurl/xproto-X11R7.0-7.0.4.tar.bz2
download_ccompile $xurl/libXau-X11R7.0-1.0.0.tar.bz2
download_ccompile $xurl/xtrans-X11R7.0-1.0.0.tar.bz2
download_ccompile $xurl/xextproto-X11R7.0-7.0.2.tar.bz2
download_ccompile $xurl/kbproto-X11R7.0-1.0.2.tar.bz2
download_ccompile $xurl/inputproto-X11R7.0-1.3.2.tar.bz2
download_ccompile $xurl/libXdmcp-X11R7.0-1.0.0.tar.bz2
download_ccompile $xurl/xf86bigfontproto-X11R7.0-1.1.2.tar.bz2
download_ccompile $xurl/bigreqsproto-X11R7.0-1.0.2.tar.bz2
download_ccompile $xurl/xcmiscproto-X11R7.0-1.1.2.tar.bz2
download_ccompile $xurl/util-macros-X11R7.0-1.0.1.tar.bz2
download_ccompile http://xcb.freedesktop.org/dist/libxcb-1.8.tar.bz2
download_ccompile $xurl/xproto-X11R7.0-7.0.4.tar.bz2
download_ccompile $xurl/libX11-X11R7.0-1.0.0.tar.bz2
download_ccompile $xurl/renderproto-X11R7.0-0.9.2.tar.bz2
download_ccompile $xurl/libXrender-X11R7.0-0.9.0.2.tar.bz2
download_ccompile $xurl/libXft-X11R7.0-2.1.8.2.tar.bz2

echo "Finished" >> log
echo "Finished"
