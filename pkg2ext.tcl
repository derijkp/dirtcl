package require Extral
set dir /home/peter/build/dirtcl8.4.8-Linux-i686/pkgs

set files [glob $dir/*]

foreach file $files {
	if {![file isdir $file]} continue
	if {![file exists $file/pkgIndex.tcl]} {
		puts "---------- skipping $file: no pkgIndex.tcl ----------"
		continue
	}
	set c [file_read $file/pkgIndex.tcl]
	puts $file:[regsub {package +ifneeded +([^ ]+) +([^ ]+) +\[list (.*)\]} $c "\\3\nextension provide \\1 \\2" temp]
	file_write $file/init.tcl $temp
}

set dir /home/peter/build/dirtcl8.4.8-Linux-i686/exts/tcllib1.7
set files [glob $dir/*]
foreach file $files {
	if {![file isdir $file]} continue
	if {![file exists $file/pkgIndex.tcl]} {
		puts "---------- skipping $file: no pkgIndex.tcl ----------"
		continue
	}
	set c [file_read $file/init.tcl]
	regexp {extension provide [^ ]+ ([^ \n]+)} $c temp v
	puts "$file -> $file$v"
	file rename $file $file$v
}

foreach file {
	base64
	crc
	dns
	log
	doctools
	uri
	ftp2
	grammar
	math
	md52
	mime
	pop3d
	ripemd
	struct
	tie
	textutil
	stooop
} {
	set file [glob $dir/*$file*]
	set c [file_read $file/pkgIndex.tcl]
	foreach line [split $c \n] {
		if {![regexp {package +ifneeded +([^ ]+) +([^ ]+) +\[list (.*)\]} $line temp name version code]} continue
		regexp {([^ ]+)\]} $code temp tclfile
		puts $dir/$name-$version
		file mkdir $dir/$name-$version
		file copy -force $file/$tclfile $dir/$name-$version
		file_write $dir/$name-$version/init.tcl "$code\nextension provide $name $version\n"
	}
	file rename $file [file dir [file dir $dir]]/obsolete
}
cd [glob [file dir [file dir $dir]]/obsolete/textutil*]
file copy adjust.tcl split.tcl tabify.tcl trim.tcl [glob $dir/textutil-*]
eval file copy [glob *.tex] {[glob $dir/textutil-*]}


set files [glob *::*]
foreach file $files {
	set list [string_split $file ::]
	set len [llength $list]
	incr len -1
	for {set i 0} {$i < $len} {incr i} {
		set dir [join [lrange $list 0 $i] /]
		puts $dir
		file mkdir $dir
	}
	file rename $file $dir/[lindex $list end]
}

set files [glob */init.tcl */*/init.tcl]
foreach file $files {
	set dir [file dir $file]
	set tail [file tail $file]
	if {[catch {
		set dest [glob ~/build/dirtcl8.4.9-Linux-i686/exts/$dir*/init.tcl]
	}]} {
		puts "cp -f $file "
	} else {
		puts "cp -f $file $dest"
	}
}

set dest /home/peter/peter-vm/build/dirtcl8.4.9-Windows-i686/exts
cp -f Extral/init.tcl $dest/Extral2.0.3/init.tcl
cp -f tclCompress/init.tcl $dest/Compress0.1.0
cp -f interface/init.tcl $dest/interface0.8.9/init.tcl
cp -f dbi/init.tcl $dest/dbi0.8.9/init.tcl
cp -f ClassyTk/init.tcl $dest/ClassyTk1.0.0/init.tcl
cp -f ClassyTcl/init.tcl $dest/Class1.0.0
cp -f abi_tools/init.tcl $dest/abi0.1.3
cp -f dbi/sqlite3/init.tcl $dest/dbi_sqlite3-0.8.9
cp -f dbi/sqlite/init.tcl $dest/dbi_sqlite0.8.9
cp -f abi_tools/io_lib/init.tcl $dest/io_lib0.1.3
