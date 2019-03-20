package ifneeded Tclx 8.4 \
[subst -nocommands {
	package require pkgtools
	set ::env(TCLX_LIBRARY) $dir/lib
	load [file join $dir [pkgtools::architecture] libtclx8.4.so] Tclx
}]
