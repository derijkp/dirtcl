package require pkgtools
set arch [pkgtools::architecture]

cd $tcl_dirtcl/lib/Img1.3

foreach pkg {zlibtcl pngtcl tifftcl jpegtcl} {
	set v [package version $pkg]
	set dest $tcl_dirtcl/exts/$pkg-$v
	mkdir $dest
	mkdir $dest/$arch
	set so [glob *$pkg*[info sharedlibextension]]
	file copy -force $so $dest/$arch
	set pkgname [file root $so]
	regsub ^lib $pkgname {} pkgname
	regsub {[-0-9.]+$} $pkgname {} pkgname
	set f [open $dest/init.tcl w]
	puts $f "package require pkgtools"
	puts $f "pkgtools::init \$dir $pkgname"
	close $f
}

file mkdir $tcl_dirtcl/exts/img
set list [package names]
foreach pkg $list {
	if {![regexp {^img::(.*)$} $pkg temp pkg]} continue
	puts "Doing $temp"
	set v [package version img::$pkg]
	set init [package ifneeded img::$pkg $v]
	set dest $tcl_dirtcl/exts/img/$pkg-$v
	mkdir $dest
	mkdir $dest/$arch
	if {$pkg ne "base"} {
		set so [glob *img$pkg*[info sharedlibextension]]
	} else {
		set so [glob *tkimg$v*[info sharedlibextension]]
	}
	file copy -force $so $dest/$arch
	set pkgname [file root $so]
	regsub ^lib $pkgname {} pkgname
	regsub {[-0-9.]+$} $pkgname {} pkgname
	set f [open $dest/init.tcl w]
	puts $f "package require pkgtools"
	puts $f "pkgtools::init \$dir $pkgname"
	close $f
}

set v [package version Img]
set dest $tcl_dirtcl/exts/Img-$v
file mkdir $dest
set init [package ifneeded Img $v]
set f [open $dest/init.tcl w]
puts $f $init
close $f
