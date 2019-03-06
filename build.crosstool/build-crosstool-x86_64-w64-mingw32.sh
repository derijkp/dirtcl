# http://www.nathancoulson.com/proj_cross.php#x86_64-w64-mingw32

mkdir ~/extern/mingw-w64
cd ~/extern/mingw-w64
wget http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v2.0.7.tar.gz
wget ftp://ftp.gnu.org/gnu/binutils/binutils-2.23.1.tar.bz2
wget ftp://ftp.gnu.org/gnu/gcc/gcc-4.8.0/gcc-4.8.0.tar.bz2

tar xvzf mingw-w64-v2.0.7.tar.gz
tar xvjf binutils-2.23.1.tar.bz2
tar xvjf gcc-4.8.0.tar.bz2

# MingwRT Headers
cd ~/extern/mingw-w64/mingw-w64-v2.0.7/mingw-w64-headers
make distclean
./configure --prefix=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot --host=x86_64-w64-mingw32
make install
ln -s x86_64-w64-mingw32 /opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot/mingw
install -d -m755 /opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot/mingw/lib 

# Binutils
cd ~/extern/mingw-w64/binutils-2.23.1
mkdir build
make distclean
cd build
../configure --prefix=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7 --target=x86_64-w64-mingw32 --with-sysroot=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32
make
make install

# GCC pass1
cd ~/extern/mingw-w64/gcc-4.8.0
mkdir build
make distclean
cd build
../configure --prefix=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7 --target=x86_64-w64-mingw32 --enable-languages=c,c++ --libexecdir=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/lib --disable-static --enable-threads=win32 --with-sysroot=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot --enable-targets=all --with-cpu=generic
make all-gcc
make install-gcc

# MingwRT Libraries
cd ~/extern/mingw-w64/mingw-w64-v2.0.7/mingw-w64-crt
export CPPFLAGS="-I/opt/crosstools/mingw-w64/x86_64-w64-mingw32/include ${CPPFLAGS}"

./configure --prefix=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot --host=x86_64-w64-mingw32
make
make install

# GCC Pass2
cd ~/extern/mingw-w64/gcc-4.8.0
mkdir build
cd build
../configure --prefix=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7 --target=x86_64-w64-mingw32 --enable-languages=c,c++ --libexecdir=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/lib --disable-static --enable-threads=win32 --with-sysroot=/opt/crosstool/gcc-4.8.0-mingw-w64-2.0.7/x86_64-w64-mingw32/sysroot --enable-targets=all --with-cpu=generic
make
make install



# http://ffmpeg.zeranoe.com/blog/?p=383
mkdir /opt/crosstool/mingw-w64-zeranoe
cd /opt/crosstool/mingw-w64-zeranoe
wget http://zeranoe.com/scripts/mingw_w64_build/mingw-w64-build-3.6.4
chmod u+x ./mingw-w64-build-3.6.4
./mingw-w64-build-3.6.4 --help
./mingw-w64-build-3.6.4 --build-type=multi --gcc-langs=c,c++,fortran,obj-c++,lto --binutils-ver=snapshot --default-configure --disable-shared --enable-gendef --enable-widl --clean-build

