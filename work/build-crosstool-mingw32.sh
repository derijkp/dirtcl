#cd ~/extern
#wget http://www.sandroid.org/imcross/IMCROSS-20090426.tar.gz
#tar xvzf IMCROSS-20090426.tar.gz
#cd IMCROSS
#make
#cp ~/IMCROSS /opt/crosstool/i386-mingw32

#http://mxe.cc/

cd ~/extern
git clone -b stable https://github.com/mxe/mxe.git
cd mxe
make gcc
make
cp -r usr /opt/crosstool/i686-pc-mingw32

cd /opt/crosstool/i686-pc-mingw32
mkdir i686-pc-mingw32/include/linux
cp -r ./lib/gcc/i686-pc-mingw32/4.7.0/include/* i686-pc-mingw32/include/linux
