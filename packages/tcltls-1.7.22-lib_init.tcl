# Initialisation of the tls package

namespace eval tls {}

set ::tls::version 1.7.22

package provide tls $::tls::version

package require pkgtools
pkgtools::init $tls::dir tls tls::version

if {[file exists [file join ${tls::dir} lib tls.tcl]]} {
	source [file join ${tls::dir} lib tls.tcl]
}
