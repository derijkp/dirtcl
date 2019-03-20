package ifneeded rbc 0.1 \
[subst -nocommands {
	set ::rbc_dir [list $dir]
	source [file join [list $dir] init.tcl]
}]
