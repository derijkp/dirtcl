namespace eval ext {}

proc ext::unknown {name version {exact {}}} {
	if {$exact eq "-exact"} {
		set error [catch {extension require -exact $name $version} result]
	} else {
		set error [catch {extension require $name $version} result]
	}
	if {$error} {
		if {[string match "can't find extension*" $result]} {
			tclPkgUnknown $name $version $exact
		} else {
			return -code $error $result
		}
	}
	return $result
}

proc ext::version_ordered {args} {
	if {[lsort -dictionary $args] eq $args} {
		return 1
	} else {
		return 0
	}
}

proc ext::version_compare {n1 n2} {
	if {[regsub {([0-9]+\.[0-9]+)\.?([A-Za-z]+[0-9]+)$} $n1 "\\1.\n\\2" n1]} {
	} else {
		regsub {([^.][0-9]+\.[0-9]+)$} $n1 {\1.0} n1
	}
	if {[regsub {([0-9]+\.[0-9]+)\.?([A-Za-z]+[0-9]+)$} $n2 "\\1.\n\\2" n2]} {
	} else {
		regsub {([^.][0-9]+\.[0-9]+)$} $n2 {\1.0} n2
	}
	if {$n1 eq $n2} {return 0}
	if {[lsort -dictionary [list $n1 $n2]] eq [list $n1 $n2]} {
		return -1
	} else {
		return 1
	}
}

if 0 {

	foreach {v1 v2} {
		tcl-8.4b1 tcl-8.4.b2
		tcl8.4 tcl8.4.1
		tcl8.4 tcl8.4.b2
		tcl8.4b2 tcl8.4
		tcl8.4b2 tcl8.4.b2
	} {
		puts [list $v1 $v2 [ext::version_compare $v1 $v2]]
	}

}

proc ext::updatecatalog_dir {pathdir {pre {}}} {
	variable catalog
	variable catalog_time
	upvar done done
	set list [glob -nocomplain $pathdir/*]
	foreach file $list {
		set tail [file tail $file]
		if {[regexp {^(.*?)-?([0-9.]+)$} $tail temp name version]} {
		} elseif {[regexp {^(.*?)-?([0-9.]+[A-Za-z0-9]+)$} $tail temp name version]} {
		} else {
			ext::updatecatalog_dir $file ${tail}::
			continue
		}
		if {[info exists done($pre$name-$version)]} continue
		lappend catalog($pre$name) [list $version $file]
		set done($pre$name-$version) 1
	}
	set catalog_time($pathdir) [file mtime $pathdir]
}

proc ext::updatecatalog {} {
	global ext_path
	variable catalog
	variable catalog_time
	if {![info exists ext_path]} {
		global env
		if {[info exists env(TCLEXTPATH)]} {
			set ext_path $env(TCLEXTPATH)
		}
	}
	foreach pathdir $ext_path {
		if {![info exists catalog_time($pathdir)] || ([file mtime $pathdir] != $catalog_time($pathdir))} {
			set update 1
		}
	}
	if {![info exists update]} return
	unset -nocomplain catalog
	foreach pathdir $ext_path {
		ext::updatecatalog_dir $pathdir
	}
	foreach name [array names catalog] {
		set catalog($name) [lsort -index 0 -command ext::version_compare -decreasing $catalog($name)]
	}
	set catalog_path $ext_path
}

proc extension {cmd args} {
	global ext_path ext::loaded
	upvar #0 ext::catalog catalog
	ext::updatecatalog
	switch $cmd {
	require {
		if {[lindex $args 0] eq "-exact"} {
			set exact 1
			foreach {temp name version} $args break
		} else {
			set exact 0
			foreach {name version} $args break
		}
		if {![info exists catalog($name)]} {
			error "can't find extension $name"
		}
		if {$version eq ""} {
			foreach {fversion dir} [lindex $catalog($name) 0] break
		} elseif {$exact} {
			set ok 0
			foreach line $catalog($name) {
				foreach {fversion dir} $line break
				if {($version eq $fversion) || [regexp ^$version\\. $fversion]} {
					set ok 1
					break
				}
			}
			if {!$ok} {
				error "can't find extension (exact) $name $version"
			}
		} else {
			foreach {fversion dir} [lindex $catalog($name) 0] break
			if {[ext::version_compare $version $fversion] != -1} {
				error "can't find extension $name $version"
			}
		}
		if {[info exists ext::loaded($name-$fversion)]} {
			return $ext::loaded($name-$fversion)
		} else {
			set f [open $dir/init.tcl]
			set c [read $f]
			close $f
			if {[info exists ::dir]} {
				set keepdir $::dir
				set ::dir $dir
				set error [catch {uplevel #0 $c} errormsg]
				set ::dir $keepdir
				if {$error} {error $errormsg}
			} else {
				set ::dir $dir
				uplevel #0 $c
				unset ::dir
			}
			return $fversion
		}
	}
	provide {
		foreach {name version} $args break
		set ext::loaded($name-$version) $version
	}
	list {
		foreach name [array names catalog] {
			foreach el $catalog($name) {set a([list $name [lindex $el 0]]) 1}
		}
		return [lsort -command ext::version_compare [array names a]]
	}
	names {
		return [lsort -command ext::version_compare [array names catalog]]
	}
	versions {
		foreach {name version} $args break
		set list {}
		foreach el $catalog($name) {
			lappend list [lindex $el 0]
		}
		return [lsort -dictionary $list]
	}
	}
}
