package require Tk

package require pkgtools
set ::rbc_dir [list $dir]
pkgtools::init $rbc_dir rbc rbc::graph

# Library files are in a subdirectory during builds/tests
if { ! [file exists [file join $rbc_dir graph.tcl]] } {
	set ::rbc_library [file join $rbc_dir library]
	source [file join $rbc_dir library graph.tcl]
} else {
	set ::rbc_library $rbc_dir
	source [file join $rbc_dir graph.tcl]
}
