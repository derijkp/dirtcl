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
