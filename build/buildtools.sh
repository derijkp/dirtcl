#!/bin/bash

function download {
    url=$1
    base=`pwd`
    file=${url##*/}
    cd $base/../downloads
    if [ ! -f "$file" ]; then
        wget -c --retr-symlinks $url
    fi
    cd $base
    test=`grep "make finished" ${file%.tar.*}/log` || true
    if [ "$test" != "" ]; then
        echo "-- already unpacked $file"
    else
        unpack $base/../downloads/$file
    fi
}

function compile {
    path=$1
    shift
    file=${path##*/}
    base=`pwd`
    echo "----------------------------------------------------------------------------------------"
    echo "---------- compiling $file ----------"
    echo "----------------------------------------------------------------------------------------" >> log
    echo "---------- compiling $file ----------" >> log
    test=""
    test=`grep "make finished" ${file%.tar.*}/log` || true
    if [ "$test" != "" ]; then
        echo "-- Skipping $file"
    else
        file=${file##*/}
        cd $base/${file%.tar.*}
	for patch in ~/dev/dirtcl/build/${file%.tar.*}-*.patch ; do
            [ -e "$patch" ] || break
            echo "$patch"
            if [ ! -f "${patch##*/}" ]; then
                patch < $patch
                cp $patch .
            fi
	done
        make clean || true
        make distclean || true
        echo "-- Configuring $file $@"
        if [[ "${file}" == "openssl-0.9.8h.tar.gz" ]]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./Configure linux-elf --prefix=$CROSSNBASE
            # CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif [[ "${file}" == "openssl-1.0.1c.tar.gz" ]]; then
            CFLAGS='-fPIC' PATH=$CROSSBIN:$PATH ./Configure linux-elf no-asm shared --prefix=$CROSSNBASE
            CFLAGS='-fPIC' PATH=$CROSSBIN:$PATH make install >> log
            CFLAGS='-fPIC' PATH=$CROSSBIN:$PATH make install >> log
        elif [[ "${file}" == "openssl-1.0.1g.tar.gz" ]]; then
            CFLAGS='-fPIC' PATH=$CROSSBIN:$PATH ./Configure linux-elf no-asm shared --prefix=$CROSSNBASE
            CFLAGS='-fPIC' PATH=$CROSSBIN:$PATH make install >> log
            CFLAGS='-fPIC' PATH=$CROSSBIN:$PATH make install >> log
        elif  [ "${file}" == "libX11-X11R7.1-1.0.1.tar.bz2" ]; then
            # cp ../libX11-1.2/src/util/makekeys.c src/util/makekeys.c
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [ "${file}" == "pcre-8.20.tar.gz" ]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE --enable-utf8 >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [ "${file}" == "libxml2-2.7.8.tar.gz" ]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE --without-python --with-pic >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [[ "${file}" == "xcb-proto-1.7.tar.bz2" ]]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE --without-python >> log
             echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [ "${file}" == "fontconfig-2.9.0.tar.gz" ]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE >> log
            cp Makefile Makefile.ori
            sed -e 's/fc-cache\//#fc-cache\//' Makefile.ori > Makefile
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [ "${file}" == "libX11-1.2.tar.bz2" ]; then
            echo "only needed for makekeys.c"
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [ "${file}" == "libgcrypt-1.4.6.tar.bz2" ]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --disable-aesni-support --disable-asm --enable-shared --prefix=$CROSSNBASE >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        elif  [ "${file}" == "bison-2.7.tar.gz" ]; then
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        else
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH ./configure --prefix=$CROSSNBASE "$@" >> log
            echo "-- Compiling $file"
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make >> log
            CFLAGS='-fPIC' PATH=$CROSSNBIN:$PATH make install >> log
        fi
        echo "make finished" >> log
        echo "make finished"
    fi
    cd $base
}

function unpack {
    path=$1
    file=${path##*/}
    echo "-- Unpacking $file"
    if [ "${file##*.}" = "gz" ]; then
        tar xzf $path
    elif [ "${file##*.}" = "xz" ]; then
        tar xJf $path
    else
        tar xjf $path
    fi
}

function ccompile {
    path=$1
    shift
    file=${path##*/}
    base=`pwd`
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
        file=${file##*/}
        cd $base/${file%.tar.*}
	for patch in ~/dev/dirtcl/build/${file%.tar.*}-*.patch ; do
            [ -e "$patch" ] || break
            echo "$patch"
            if [ ! -f "${patch##*/}" ]; then
                patch < $patch
                cp $patch .
            fi
	done
        make distclean || true
        echo "-- Configuring $file $@"
        CFLAGS='-fPIC' ./configure --host=$HOST --build=i386-linux --prefix=$CROSSNBASE --enable-malloc0returnsnull "$@" >> log
        echo "-- Compiling $file"
        CFLAGS='-fPIC' make install >> log
        echo "make finished" >> log
        echo "make finished"
    fi
}

function download_ccompile {
    keeppwd=`pwd`
    url=$1
    shift
    file=${url##*/}
    echo "----------------------------------------------------------------------------------------"
    echo "---------- $file ----------"
    echo "----------------------------------------------------------------------------------------" >> log
    echo "---------- $file ----------" >> log
    download $url
    file=${url##*/}
    # not checked for all of them (most done with compile)
    ccompile "../downloads/$file" "$@"
    cd $keeppwd
}

function download_compile {
    keeppwd=`pwd`
    url=$1
    shift
    file=${url##*/}
    echo "----------------------------------------------------------------------------------------"
    echo "---------- $file ----------"
    echo "----------------------------------------------------------------------------------------" >> log
    echo "---------- $file ----------" >> log
    download $url
    file=${url##*/}
    # not checked for all of them (most done with compile)
    compile "../downloads/$file" "$@"
    cd $keeppwd
}
