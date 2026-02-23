if {[catch {package require Tcl 8.5-}]} {
	error "versions of Tcl < 8.5 not supported"
}
package require pkgtools
load [file join $dir [pkgtools::architecture] libTktable2.12.1.so] Tktable
set initScript [file join $dir tkTable.tcl]
if {[file exists $initScript]} {
    source -encoding utf-8 $initScript
}
