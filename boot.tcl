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
