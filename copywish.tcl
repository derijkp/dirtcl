#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

set len [llength $argv]
puts argv:$argv
if {$len  != 3} {
	puts stderr "format is :[info nameofexecutable] executable newexecutable newicon"
	exit 1
}

foreach {oldfile file newiconfile} $argv break
set oldiconfile [file dir $oldfile]/lib/wish.ico

if 0 {
set oldfile /home/peter/peter-vm/tcl/dirtcl/dirtcl/wish84.exe
set file /home/peter/peter-vm/tcl/dirtcl/dirtcl/test.exe
set oldiconfile /home/peter/peter-vm/tcl/dirtcl/dirtcl/wish.ico
set newiconfile /home/peter/peter-vm/tcl/dirtcl/dirtcl/testnew.ico
}

proc readfile {name} {
  set fd [open $name]
  fconfigure $fd -translation binary
  set data [read $fd]
  close $fd
  return $data
}

proc writefile {name data} {
  set fd [open $name w]
  fconfigure $fd -translation binary
  puts -nonewline $fd $data
  close $fd
}

# decode Windows .ICO file contents into the individual bit maps
proc decICO {dat} {
	set result {}
	binary scan $dat sss - type count
	for {set pos 6} {[incr count -1] >= 0} {incr pos 16} {
		binary scan $dat @${pos}ccccssii w h cc - p bc bir io
		if {$cc == 0} { set cc 256 }
		#puts "pos $pos w $w h $h cc $cc p $p bc $bc bir $bir io $io"
		binary scan $dat @${io}a$bir image
		lappend result ${w}x${h}/$cc $image
	}
	return $result
}


set data [readfile $oldfile]
set oldicon [readfile $oldiconfile]
set newicon [readfile $newiconfile]
array set newimg [decICO $newicon]
foreach {k v} [decICO $oldicon] {
	if {[info exists newimg($k)]} {
		set len [string length $v]
		set pos [string first $v $data]
		if {$pos < 0} {
			puts " icon $k: NOT FOUND"
		} elseif {[string length $newimg($k)] != $len} {
			puts " icon $k: NOT SAME SIZE"
		} else {
			binary scan $data a${pos}a${len}a* prefix - suffix
			set data "$prefix$newimg($k)$suffix"
			puts " icon $k: replaced"
		}
	}
}
writefile $file $data
