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
