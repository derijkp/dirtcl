target="mingw32msvc"
arch=i386
base=~/extern/deps-$arch-$target
HOST=i686-pc-mingw32

mkdir $base
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
            PATH=$CROSSBIN:$PATH ./Configure linux-elf --enable-shared --prefix=$CROSSNBASE
            # PATH=$CROSSBIN:$PATH make install >> log
        elif  [ "${file}" == "pcre-8.20.tar.gz" ]; then
            ./configure --prefix=$CROSSNBASE --enable-utf8 >> log
        elif  [ "${file}" == "libxml2-2.7.8.tar.gz" ]; then
            ./configure --prefix=$CROSSNBASE --without-python >> log
        elif  [ "${file}" == "libgcrypt-1.4.6.tar.bz2" ]; then
            ./configure --disable-aesni-support --disable-asm --enable-shared --prefix=$CROSSNBASE >> log
        elif  [ "${file}" == "zlib-1.2.7.tar.gz" ]; then
            PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE
            cp $CROSSNBASE/lib/crt2.o $CROSSBASE/lib/gcc/i386-mingw32msvc/3.4.1/crtbegin.o $CROSSBASE/lib/gcc/i386-mingw32msvc/3.4.1/crtend.o .
            PATH=$CROSSNBIN:$PATH make
            PATH=$CROSSNBIN:$PATH make install
        else
            ./configure --prefix=$CROSSNBASE --host=$HOST --build=i386-linux >> log
        fi
	echo "-- Compiling $file"
	make install >> log
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

for url in \
http://zlib.net/zlib-1.2.7.tar.gz \
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
