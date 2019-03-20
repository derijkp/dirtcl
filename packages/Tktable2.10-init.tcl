package require Tcl 8.2
package require pkgtools
load [file join $dir [pkgtools::architecture] libTktable2.10.so] Tktable
extension provide Tktable 2.10
