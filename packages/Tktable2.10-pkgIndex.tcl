if {[catch {package require Tcl 8.2}]} return
package ifneeded Tktable 2.10 [subst -nocommands {
    package require pkgtools
    load [file join $dir [pkgtools::architecture] libTktable2.10.so] Tktable
}]

