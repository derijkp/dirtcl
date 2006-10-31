#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

set tclversion 8.4.14

set platform $tcl_platform(platform)
set basetcldir [file normalize ../tcl$tclversion]
set basetkdir [file normalize ../tk$tclversion]
if {$platform eq "unix"} {
	set tcldir [file normalize ../tcl$tclversion/unix]
	set tkdir [file normalize ../tk$tclversion/unix]
} elseif {$platform eq "windows"} {
	set tcldir [file normalize ../tcl$tclversion/win]
	set tkdir [file normalize ../tk$tclversion/win]
	set sh C:/msys/1.0/bin/sh.exe
} else {
	error "only supported on unix and windows ... yet"
}

set script [file normalize [info script]]
# set script /home/peter/dev/dirtcl/makedirtcl.tcl
if {"$tcl_platform(platform)"=="unix"} {
	while 1 {
		if {[catch {set script [file normalize [file readlink $script]]}]} break
	}
}
if {$script eq ""} {set scriptdir [pwd]} else {set scriptdir [file dir $script]}

set dirtcldir [pwd]

if {[llength [glob -nocomplain $dirtcldir/*]]} {
	error "error: current directory (in which dirtcl should be build) is not empty"
}

set dir [file dir [info script]]
if {$dir ne {}} {cd $dir}

proc file_read {file} {
	set f [open $file]
	set c [read $f]
	close $f
	return $c
}

proc file_write {file data} {
	set f [open $file w]
	puts $f $data
	close $f
}

proc rewrite_before {pattern c insert} {
	set pos [string first $pattern $c]
	return [string range $c 0 [expr {$pos-1}]]$insert[string range $c $pos end]
}

proc rewrite_after {pattern c insert} {
	set pos [expr {[string first $pattern $c] + [string length $pattern]}]
	return [string range $c 0 [expr {$pos-1}]]$insert[string range $c $pos end]
}

proc outexec {args} {
	global platform
	if {$platform eq "unix"} {
		set f [open "|$args" r+]
		while {![eof $f]} {
			set line [gets $f]
			puts $line
		}
		close $f
	} else {
		catch {eval exec $args} e
		puts $e
	}
}

set preinitcode {
#ifdef DIRTCL
static char preInitCmd[] = 
"proc file_resolve {file {lastlinkVar {}}} {\n"
"	if {$lastlinkVar ne \"\"} {upvar $lastlinkVar lastlink}\n"
"	if {$::tcl_platform(platform) eq \"unix\"} {\n"
"		set file [file normalize $file]\n"
"		while 1 {\n"
"			if {[catch {set link [file readlink $file]}]} break\n"
"			if {[file pathtype $link] ne \"absolute\"} {set link [file normalize [file join [file dir $file] $link]]}\n"
"			set lastlink $file\n"
"			set file [file normalize $link]\n"
"		}\n"
"	}\n"
"	return $file\n"
"}\n"
"set tcl_executable [file_resolve [info nameofexecutable] tcl_lastlink]\n"
"set tcl_root [file join [file dir $tcl_executable] lib]\n"
"set tcl_library [file join $tcl_root tcl$tcl_version]\n"
"set tcl_libPath [list $tcl_library $tcl_root]\n"
"set dirtcl 1\n"
;
static char initScript[] =
"source [file join $tcl_root boot.tcl]\n"
;
#endif /* DIRTCL */
}

# code to do the conversion
# -------------------------
foreach dir [list $basetcldir/unix $basetcldir/win] {
puts "converting $dir/tclAppInit.c"
set file $dir/tclAppInit.c
if {![file exists $file.orig]} {
	file copy $file $file.orig
}
set c [file_read $file.orig]
set c [rewrite_before "#include \"tcl.h\"" $c "#define DIRTCL 1\n"]
set c [rewrite_before "int\nTcl_AppInit(interp)" $c $preinitcode]
set c [rewrite_before "if (Tcl_Init(interp) == TCL_ERROR)" $c {
#ifdef DIRTCL
    Tcl_Obj *temp;
    TclSetPreInitScript(preInitCmd);
#endif /* DIRTCL */
    }]
set c [rewrite_before "return TCL_OK" $c {
#ifdef DIRTCL
    if (Tcl_Eval(interp, initScript) == TCL_ERROR) {
        return (TCL_ERROR);
    };
    temp = Tcl_GetVar2Ex(interp,"tcl_boot",NULL,TCL_GLOBAL_ONLY);
    if (temp != NULL) {
	Tcl_IncrRefCount(temp);
        TclSetStartupScriptFileName(Tcl_GetStringFromObj(temp,NULL));
    }
#endif /* DIRTCL */
    }]
file_write $file $c
}

# convert winMain.c
# -----------------
puts "converting winMain.c"
set file $basetkdir/win/winMain.c
if {![file exists $file.orig]} {
	file copy $file $file.orig
}
set c [file_read $file.orig]
set c [rewrite_before "#include \"tcl.h\"" $c "#define DIRTCL 1\n"]
set c [rewrite_before "int\nTcl_AppInit(interp)" $c $preinitcode]
set c [rewrite_before "if (Tcl_Init(interp) == TCL_ERROR)" $c {
#ifdef DIRTCL
    Tcl_Obj *temp;
    TclSetPreInitScript(preInitCmd);
#endif /* DIRTCL */
    }]
set c [rewrite_after {Tcl_SetVar(interp, "tcl_rcFileName", "~/wishrc.tcl", TCL_GLOBAL_ONLY);} $c {
#ifdef DIRTCL
if (Tcl_Eval(interp, initScript) == TCL_ERROR) {
	return (TCL_ERROR);
};
temp = Tcl_GetVar2Ex(interp,"tcl_boot",NULL,TCL_GLOBAL_ONLY);
if (temp != NULL) {
	Tcl_IncrRefCount(temp);
	TclSetStartupScriptFileName(Tcl_GetStringFromObj(temp,NULL));
}
#endif /* DIRTCL */
}]
set c [rewrite_after {"set tcl_libPath [list $tcl_library $tcl_root]\n"} $c {
	"set tk_library [file join $tcl_root tk$tcl_version]\n"
}]
file_write $file $c


# compile Tcl
# -----------------------

puts "compiling tcl"
cd $tcldir
if {$platform eq "unix"} {
	outexec sh ./configure --disable-shared --disable-threads --disable-symbols -prefix=$dirtcldir
} else {
	outexec $sh ./configure --enable-shared --disable-threads --disable-symbols -prefix=$dirtcldir
}
catch {outexec make} e
catch {outexec make install} e

# compile Tk
# ----------------------
puts "compiling tk"
cd $tkdir
outexec sh ./configure --enable-shared --disable-threads --disable-symbols --with-tcl=$tcldir -prefix=$dirtcldir
catch {outexec make} e
catch {outexec make install} e

# Convert to dirtcl
# -----------------
puts "Converting to dirtcl"
set files [glob $dirtcldir/bin/*]
eval file rename $files $dirtcldir
file delete $dirtcldir/bin
if {$platform eq "unix"} {
	cd $dirtcldir
	set tcl [lindex [glob tcl*] 0]
	catch {
		set wish [lindex [glob wish*] 0]
		eval file delete -force $wish
		exec ln -s $tcl $wish
	}
	exec ln -s $tcl tclsh
	exec ln -s $tcl wish
}
file delete -force $dirtcldir/man
# write boot.tcl
file copy $scriptdir/boot.tcl $dirtcldir/lib/boot.tcl
set tcllibdir [glob $dirtcldir/lib/tcl[string index $tcl_version 0]*]
file copy $scriptdir/extension.tcl $tcllibdir
set f [open $tcllibdir/tclIndex a]
puts $f {set auto_index(extension) [list source [file join $dir extension.tcl]]}
puts $f {set auto_index(ext::unknown) [list source [file join $dir extension.tcl]]}
close $f
set c [file_read $tcllibdir/init.tcl]
set c [string map {{
if {![info exists auto_path]} {
    if {[info exists env(TCLLIBPATH)]} {
	set auto_path $env(TCLLIBPATH)
    } else {
	set auto_path ""
    }
}
} {
if {![info exists auto_path]} {
	set auto_path ""
}
set tcl_pkgPath [file join [file dirname [file dirname [info library]]] pkgs]
set tclDefaultLibrary [info library]
}} $c]
file_write $tcllibdir/init.tcl $c
file mkdir $dirtcldir/pkgs
file mkdir $dirtcldir/exts
file copy [lindex [glob $scriptdir/pkgtools*] 0] $dirtcldir/exts


# set ext for platform
# --------------------
if {$platform eq "windows"} {
	set ext .exe
} else {
	set ext ""
}

if {$platform eq "windows"} {
	file copy -force $tkdir/rc/wish.ico $dirtcldir/lib
}


# setup example
# -------------
puts "setup example"
catch {file mkdir $dirtcldir/apps/example}
set f [open $dirtcldir/apps/example/example.tcl w]
puts $f {puts "Hello world: $tcl_interactive"
}
close $f
if {$platform eq "unix"} {
	set keeppwd [pwd]
	cd $dirtcldir
	exec ln -s [lindex [glob tclsh*] 0] example$ext
	cd $keeppwd
} else {
	file copy -force [lindex [glob $dirtcldir/tclsh*] 0] $dirtcldir/example$ext
}

# setup tkexample
# ---------------
puts "setup tkexample"
catch {file mkdir $dirtcldir/apps/tkexample}
set f [open $dirtcldir/apps/tkexample/tkexample.tcl w]
puts $f {package require Tk
button .b -text "Hello world" -command {puts "Hello world"}
pack .b -fill both -expand yes
}
close $f
if {$platform eq "unix"} {
	set keeppwd [pwd]
	cd $dirtcldir
	exec ln -s [lindex [glob tclsh*] 0] tkexample$ext
	cd $keeppwd
} else {
	file copy -force [lindex [glob $dirtcldir/wish*] 0] $dirtcldir/tkexample$ext
}

# setup tkdemos
# ---------------
puts "setup tkexample"
file copy $basetkdir/library/demos $dirtcldir/apps
set f [open $dirtcldir/apps/demos/widget]
set c [read $f]
close $f
set f [open $dirtcldir/apps/demos/demos.tcl w]
puts $f "package require Tk"
puts $f $c
close $f
if {$platform eq "unix"} {
	set keeppwd [pwd]
	cd $dirtcldir
	exec ln -s [lindex [glob tclsh*] 0] demos$ext
	cd $keeppwd
} else {
	file copy -force [lindex [glob $dirtcldir/wish*] 0] $dirtcldir/demos$ext
}

cd $dirtcldir
