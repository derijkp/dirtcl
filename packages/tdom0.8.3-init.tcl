package require pkgtools
load [file join $dir [pkgtools::architecture] libtdom0.8.3.so]
source [file join $dir tdom.tcl]
extension provide tdom 0.8.3
