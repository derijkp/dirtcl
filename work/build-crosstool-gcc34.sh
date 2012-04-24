# old gcc needed to compile older glibc
# build using:

mkdir ~/extern
cd ~/extern
wget ftp://ftp.gnu.org/pub/gnu/gcc/gcc-3.4.6/gcc-3.4.6.tar.gz
tar xzf gcc-3.4.6.tar.gz
cd gcc-3.4.6
# cp ~/dev/dirtcl/work/gcc-multilib-fix-v3.3.x-to-v4.2.3.debian.x86_64.diff.txt .
# patch -p0 < gcc-multilib-fix-v3.3.x-to-v4.2.3.debian.x86_64.diff
mkdir /home/peter/apps/
mkdir ~/extern/gcc-3.4.6-objdir
cd ~/extern/gcc-3.4.6-objdir
../gcc-3.4.6/configure --prefix=/home/peter/apps/gcc-3.4.6
make
make install
