if 0 {
# install crosstools and compile a toolchain for crosscompilation
wget -c http://kegel.com/crosstool/crosstool-0.43.tar.gz
tar -xzvf crosstool-0.43.tar.gz
cd ~/extern/crosstool-0.43
# edit demo-i686.sh to uncomment the target wanted
cedit demo-i686.sh

# PATH because of error with building gcc-3.3.6-glibc-2.2.2 with make 3.82
PATH=/home/peter/apps/make3.81/bin:$PATH ./demo-i686.sh

# getting gcc-3.3.6-glibc-2.3.2.dat to compile on fedora 16
# install compat-gcc-34
mkdir bin
ln -s /usr/bin/gcc34 bin/gcc
PATH=~/extern/crosstool-0.43/bin:/home/peter/apps/make3.81/bin:$PATH ./demo-i686.sh
}

# crosscompile dependencies (using crosstools installed toolchain)
unset env(CROSS_COMPILE)
unset env(DISCIMAGE)
unset env(CROSSTARGET)
unset env(TARGET)
unset env(CROSSBASE)
unset env(CROSSNBASE)
unset env(CROSSBIN)
unset env(CROSSNBIN)
unset env(BASE)
unset env(LDFLAGS)
unset env(CPPFLAGS)
unset env(CFLAGS)
unset env(CC)
unset env(AR)
unset env(LD)
unset env(RANLIB)
#set env(CROSSTARGET) "gcc-3.3.6-glibc-2.2.2"
set env(CROSSTARGET) "gcc-3.3.6-glibc-2.3.2"
set env(TARGET) "i686-unknown-linux-gnu"
set env(CROSSBASE) "/opt/crosstool/$env(CROSSTARGET)/$env(TARGET)"
set env(CROSSNBASE) "$env(CROSSBASE)/$env(TARGET)"
set env(CROSSBIN) "$env(CROSSBASE)/bin"
set env(CROSSNBIN) "$env(CROSSNBASE)/bin"
set env(BASE) ~/extern/deps-gcc-3.3.6-glibc-2.3.2
set env(LDFLAGS) "-L$env(CROSSNBASE)/lib"
set env(CPPFLAGS) "-I$env(CROSSNBASE)/include"
set env(CFLAGS) "-I$env(CROSSNBASE)/include"
#set env(CC) $env(CROSS_COMPILE)gcc
#set env(AR) $env(CROSS_COMPILE)ar
#set env(LD) $env(CROSS_COMPILE)ld
#set env(RANLIB) $env(CROSS_COMPILE)ranlib
set env(CROSS_COMPILE) "$env(TARGET)-"
set env(DISCIMAGE) $env(CROSSNBASE)

proc putslog {line} {
	global log env
	puts $line
	set logfile [file join $env(BASE) log]
	set log [open $logfile a]
	puts $log $line
	close $log
}

proc outexec {args} {
	global env
	set keepenv {}
	if {[lindex $args 0] eq "-env"} {
		putslog "setting env [lindex $args 1]"
		foreach {key value} [lindex $args 1] {
			if {[info exists env($key)]} {
				lappend keepenv $key $env($key)
			} else {
				lappend keepenv $key {}
			}
			set env($key) $value
		}
		set args [lrange $args 2 end]
	}
	set platform $::tcl_platform(platform)
	if {$platform eq "unix"} {
		set f [open "|$args" r+]
		while {![eof $f]} {
			set line [gets $f]
			putslog $line
		}
		close $f
	} else {
		putslog "----- $args -----"
		set error [catch {eval exec $args} e]
		if {$error} {puts ****ERROR****}
		putslog $e
	}
	foreach {key value} $keepenv {
		set env($key) $value
	}
}

proc pkg_download url {
	putslog "----- Downloading $url -----"
	set file [file tail $url]
	if {$file eq "download"} {
		set nfile [lindex [file split $url] end-1]
		if {![file exists $nfile]} {
			catch {outexec wget -c $url}
			putslog "Renaming to $nfile"
			file rename $file $nfile
		}
		set file $nfile
	} else {
		if {![file exists $file]} {
			catch {outexec wget -c $url}
		}
	}
	set ext [file extension $file]
	putslog "----- Unpacking $file -----"
	set dir [file root [file root $file]]
	switch $ext {
		.gz {
			catch {outexec tar xvzf $file}
		}
		.bz2 {
			catch {outexec tar xvjf $file}
		}
		default {
			error "extension \"$ext\""
		}
	}
	return $dir
}

proc pkg_crosscoompile {url {configurecmd ./configure}} {
	global env
	# compile zlib
	cd $env(BASE)
	putslog ----------------------------------------------------------------------
	set dir [pkg_download $url]
	cd $env(BASE)/$dir
	catch {outexec make distclean}
	putslog "----- Configure $dir -----"
	outexec -env [list PATH $env(CROSSNBIN):$env(PATH)] {*}$configurecmd --prefix=$env(CROSSNBASE)
	putslog "----- make $dir -----"
	outexec -env [list PATH $env(CROSSNBIN):$env(PATH)] make install
	# PATH=$CROSSNBIN:$PATH make install
	cd $env(BASE)
}

proc repkg_crosscoompile url {
	set dir [file root [file root $url]]
	if {$dir eq "download"} {
		set nfile [lindex [file split $url] end-1]
		set dir [file root [file root $nfile]]
	}
	global env
	# compile zlib
	putslog "----- Configure $dir -----"
	outexec -env [list PATH $env(CROSSNBIN):$env(PATH)] ./configure --prefix=$env(CROSSNBASE)
	putslog "----- make $dir -----"
	outexec -env [list PATH $env(CROSSNBIN):$env(PATH)] make install
	# PATH=$CROSSNBIN:$PATH make install
}

file mkdir $env(BASE)
cd $env(BASE)

# compile zlib
pkg_crosscoompile http://zlib.net/zlib-1.2.5.tar.gz

# compile libpng
pkg_crosscoompile https://sourceforge.net/projects/libpng/files/libpng15/older-releases/1.5.2/libpng-1.5.2.tar.gz/download

# compile expat
pkg_crosscoompile http://sourceforge.net/projects/expat/files/expat/2.0.1/expat-2.0.1.tar.gz/download

# compile libxml2 (for e.g. monetdb)
pkg_crosscoompile ftp://xmlsoft.org/libxml2/libxml2-2.7.2.tar.gz

# compile pcre (for e.g. monetdb)
pkg_crosscoompile ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.20.tar.gz

# compile freetype
pkg_crosscoompile http://sourceforge.net/projects/freetype/files/freetype2/2.4.4/freetype-2.4.4.tar.gz/download

# compile openssl
pkg_crosscoompile http://www.openssl.org/source/openssl-0.9.8h.tar.gz "./Configure linux-generic32"

# libX11 + dependencies
#

pkg_crosscoompile http://pkgconfig.freedesktop.org/releases/pkg-config-0.18.1.tar.gz
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/xproto-X11R7.1-7.0.5.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/lib/libXau-X11R7.1-1.0.1.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/lib/xtrans-X11R7.0-1.0.0.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/xextproto-X11R7.0-7.0.2.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/kbproto-X11R7.0-1.0.2.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/inputproto-X11R7.0-1.3.2.tar.gz
# pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/lib/libXi-X11R7.1-1.0.1.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/lib/libXdmcp-X11R7.1-1.0.1.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/xf86bigfontproto-X11R7.0-1.1.2.tar.bz2
pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/bigreqsproto-X11R7.0-1.0.2.tar.bz2

#pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/renderproto-X11R7.0-0.9.2.tar.bz2
#pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/lib/libXrender-X11R7.1-0.9.1.tar.bz2
#pkg_crosscoompile http://download.savannah.gnu.org/releases/freetype/freetype-2.4.4.tar.gz
#pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/lib/libXft-X11R7.0-2.1.8.2.tar.bz2

pkg_crosscoompile http://xorg.freedesktop.org/releases/X11R7.1/src/proto/xcmiscproto-X11R7.0-1.1.2.tar.bz2
# only for makekeys.c patch
pkg_download http://xorg.freedesktop.org/releases/individual/lib/libX11-1.2.tar.bz2
# compile libX11
set dir [pkg_download http://xorg.freedesktop.org/releases/X11R7.1/src/lib/libX11-X11R7.1-1.0.1.tar.bz2]
cd $env(BASE)/libX11-X11R7.1-1.0.1
cp ../libX11-1.2/src/util/makekeys.c  src/util/makekeys.c
catch {outexec make distclean}

putslog "----- Configure $dir -----"
cd $env(BASE)/libX11-X11R7.1-1.0.1
outexec -env [list PKG_CONFIG_PATH $env(CROSSNBASE)/lib/pkgconfig X11_CFLAGS "-I$env(CROSSNBASE)/include" X11_LIBS "-L$env(CROSSNBASE)/lib" PATH $env(CROSSNBIN):$env(PATH)] ./configure --prefix=$env(CROSSNBASE)

cd $env(BASE)/libX11-X11R7.1-1.0.1
putslog "----- make $dir -----"
outexec -env [list PATH $env(CROSSNBIN):$env(PATH)] make install


# build dirtl
file delete ~/tcl/dirtcl
catch {file delete -force {*}[glob ~/tcl/dirtcl8.5.11-compat/*]}
file mkdir ~/tcl/dirtcl8.5.11-compat
cd ~/tcl
exec ln -s dirtcl8.5.11-compat dirtcl
cd ~/tcl/dirtcl
# edit file, comment out: lines for making wish (lines after target wish@EXEEXT@:)
cedit ~/tcl/tk8.5.11/unix/Makefile.in
outexec -env [list PATH $env(CROSSNBIN):$env(PATH)]  ~/dev/dirtcl/makedirtcl.tcl
# PATH=$CROSSNBIN:$PATH make install
