set tcl_dirtcl [file dir $tcl_root]
if {$tcl_platform(platform) eq "windows" } {catch {console hide}}
set auto_path [list $tcl_library $tcl_root $tcl_dirtcl/lib $tcl_dirtcl/pkgs]
if {[info exists tk_library]} {
	lappend auto_path $tk_library
}
set ext_path [list $tcl_dirtcl/exts]
package unknown ext::unknown

set app_base [string tolower $tcl_executable]
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
	puts "booting from $bootscript"
	if { ![file isfile $bootscript] } {
		error "Application directory not found. This executable will only work correctly when it is located in its application directory. It can be run from another location by using a link to it"
	}
	set tcl_interactive 0
	source $bootscript
}
