set tcl_dirtcl [file dir $tcl_root]
if {$tcl_platform(platform) eq "windows" } {catch {console hide}}
set auto_path [list $tcl_library $tcl_root $tcl_dirtcl/lib $tcl_dirtcl/pkgs]
if {[info exists tk_library]} {
	lappend auto_path $tk_library
}
set ext_path [list $tcl_dirtcl/exts]
package unknown ext::unknown

if {[info exists tcl_lastlink] && ([file dir $tcl_lastlink] eq [file dir $tcl_executable])} {
	set app_base [string tolower $tcl_lastlink]
} else {
	set app_base [string tolower $tcl_executable]
}
regexp {^(.+?)([0-9.]*)(\.exe)?$} [file tail $app_base] temp app_base app_version
if {$app_base eq "tclsh" } {
	if {[lindex $argv 0] eq "-e"} {
		puts [eval [lindex $argv 1]]
		exit
	}
} elseif {$app_base eq "tca" } {
	package require Tk
	if {[file normalize $argv0] eq "[file normalize $tcl_executable]"} {error "no file to run given"}
	if {![llength $argv]} {
		if {![file exists $argv0]} {error "file $argv0 does not exist"}
		set f [open $argv0]
		set data [read $f]
		close $f
		foreach {tca_host tca_cookie srcfile argv} $data break
		set checkupdate 1
	} else {
		foreach {tca_host tca_cookie srcfile argv} $argv break
		set checkupdate 0
	}
	package require tca
	if {$checkupdate && [tca_updateneeded]} {
		tca_update tca_update$tcl_platform(execextension)
		exec [file join $tca_base tca_update$tcl_platform(execextension)] $tca_host $tca_cookie $srcfile $argv &
		exit
	}
	set tcl_boot [file join $tcl_dirtcl $srcfile]
	set argv0 $tcl_boot
} elseif {$app_base eq "wish" } {
	package require Tk
} elseif {$app_base eq "console" } {
	package require Tk
	catch {console show}
} else {
	set bootscript [file join $tcl_dirtcl apps $app_base$app_version $app_base.tcl]
	if { ![file isfile $bootscript] } {
		set bootscript [lindex [lsort -dictionary [glob -nocomplain [file join $tcl_dirtcl apps $app_base* $app_base.tcl]]] end]
	}
	if { ![file isfile $bootscript] } {
		error "Application directory not found. This executable will only work correctly when it is located in its application directory. It can be run from another location by using a link to it"
	}
	if {[file normalize [info nameofexecutable]] ne [file normalize $argv0]} {
		if {[info exists argv0]} {set argv [linsert $argv 0 $argv0]}
		set argv0 $bootscript
	}
	set tcl_boot $bootscript
}
