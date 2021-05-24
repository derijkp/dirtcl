dirtcl
====== 
Tool to create a directory based, standalone/portable version of Tcl
       Copyright Peter De Rijk (VIB/University of Antwerp)

dirtcl is a tool to create portable, self-contained (Tcl based)
applications that can be "installed" by just copying (or unpacking) a
directory anywhere on the host system, without interfering with the
system it is installed on, providing easy deployment on a wide range of
systems:

* binaries are compiled for wide compatibility (using Holy Build Box):
They will work on that centos6 cluster you still have going somewhere (due
to compatibility problems) as well as on the latest ubuntu.
* depency hell is avoided by including the correct versions of all
dependencies (binaries libraries, external tools) into one self-contained
application directory directory.
* Can be run from anywhere in the filing system (no root needed). The
application directory can be included in the PATH, but a softlink to the
application executable in a directory in the PATH will also work (dirtcl
will find application directory based on the link)

dirtcl itself (of course) is as a portable application directory of Tcl/Tk.
It comes by default with several applications/executables: tclsh, wish,
demos (The Tk demos). New ones can be easily added.

Making dirtcl based applications
================================
If the tclsh executable in a dirtcl has a name different from tclsh or wish (by renameing or 
copying, or, in Linux, a softlink made to it that is also in the dirtcl directory), an application
will be started instead of the plain tclsh. The application code must be in the directory name apps.
e.g. The "demo" executable that is by default installed in the dirtcl, will actually start tcl, and
run the file apps/demos/demos.tcl in the dirtcl. There can be more than one app in a dirtcl.

So to make a basic application directory for your Tcl based application (lets say "helloworld"):
* Get and unpack the binary dirtcl distribution for the targeted architecture (Linux
64 bit, Linux 32 bit, Windows)
* cd to the unpacked directory (paths in the rest are relative to this directory)
* Make a directory apps/helloworld (in the appdir)
* Make a file apps/helloworld/helloworld.tcl with the Tcl code that starts the application
* For Linux: make a softlink named helloworld to the actual tclsh binary (tclsh8.5): ln -s tclsh8.5 helloworld
* For Windows: make a copy of tclsh8.5 with the name helloworld.exe

Of course you can add more tcl files, dependent binaries, etc. to either the app/helloworld or dirtcl directory.
For using these, the following global variables are defined
* tcl_dirtcl: full path to the dirtcl directory
* dirtcl: set to 1 (exists in a dirtcl)
* app_base: base name of the executable used to start dirtcl
* app_version: version part of the executable used to start dirtcl

Tcl Extensions
--------------
The tclsh in a dirtcl will not look in the usual places for extension packages, nor will
it honor the TCLLIBPATH environment variable. Typical extensions will only be searched in the 
subdirectory pkgs of dirtcl. Of course you can extend the search as usual by added directories to 
the auto_path variable.

A special kind of extension packages can be installed in the exts directory. These will be searched 
by name of the directory in stead of using a pkgIndex.tcl. They must contain a file init.tcl, that 
will be used to initiate the package upon a package require


Portable binaries
-----------------
You can add external or your own extra binaries by e.g. making a directory bin in the appdir
and placing them there. Then use 
```
set env(PATH) $tcl_dirtcl/bin:$env(PATH)
```
to preferentially use the included binaries, or, if you only want to use included binaries:
```
set env(PATH) $tcl_dirtcl/bin
```

These should also be compiled to be portable (so they also run on
e.g. older Linux systems). You can build these using the same
infrastructure as is used for building dirtcl (see further).  Building
portable binaries is based on Holy Build Box
(https://github.com/phusion/holy-build-box), which uses docker to provide
a compatible build environment. So access to docker is needed for this.

It's use is somewhat simplified (you don't have to call docker yourself)
using build scripts. You can find an (extensive) example in the build dir:
hbb_build_packages.sh builds a lot of C based Tcl extensions in a
portable way. This code will start up a Linux
environment where the (dirtcl) src directory is mounted on /io, and the
build directory (default ~/build/bin-$arch) mounted on /build,
and then run the rest of the script in this environment.
You can test/debug the build process interactively by starting a shell in the build environment using
```
./build/start_hbb.sh
```

The build scripts support following options
* -b: use -b 32 for building 32 bit binaries, or -b 64 (default) for 64 bit binaries
* -builddir: can be used to specify another (top) build directory than default (~/build/tcl$arch)

If some libraries cannot be statically compiled into the binaries, you can
build portable shared libraries with the needed version, place them in the dirtcl (e.g. $tcl_dirtcl/lib)
and force their use with
```
set ::env(LD_LIBRARY_PATH) $tcl_dirtcl/lib:$::env(LD_LIBRARY_PATH)
```

Compared
--------
Tcl starkits/tclkits can also be used for binary distribution. These
have the advantage of being contained in a single file executable instead
of a directory, but
* If your application depends on external tools that do not support the
Tcl virtual file system used in tclkits, dirtcl is a lot easier and more efficient
* In dirtcl you can more easily change your application: directly in the directory without
any tooling (unpacking, packing etc. in tclkit)
* A dirtcl can have multiple commands/applications in one distribution

Versus system based package managers:
* As a developer, making and distributing packages for x number of different package
managers, distributions is an enormous amount of work, and then you still
cannot support everything (using dirtcl you, easily, make one package that
will work on all systems)
* The user often still ends up in dependency hell (because packages are
not made for their specific version of their specific distribution, or not tested on it)
* The user requires root access

Versus docker
* Users would have to install docker and learn how to use docker; They might even
not be able to do this, as it requires root.
* you would have to learn how to use docker.
* docker images will be a lot bigger, as they include entire Linux
distributions

building dirtcl
===============
makedirtcl.tcl will make a selfcontained Tcl/Tk distribution (dirtcl), that 
can be used to create a Tcl/Tk based application directory.
It will compile a customized version of Tcl and Tk, that can exist next to 
different versions with different sets of extensions without interference, not
from a system installed version, nor from other dirtcls.

Installation: build script
--------------------------
The easiest way to build a distributable dirtcl (compatible with older
systems) on linux is to run the build/hbb_build_dirtcl.sh script. It will
use the Holy Build Box (Holy Build Box uses docker, so access to docker is
needed) to build a distributable portable application directory. 

For making the 64 bit version, use:
./build/hbb_build_dirtcl.sh
This wil install it by default in the directory ~/build/bin-x86_64/dirtcl$version-x86_64
You can change the build directory (~/build/bin-x86_64) using the --builddir option. 

For the 32 bit version (installed by default in ~/build/bin-ix86/dirtcl$version-ix86), use:
./build/hbb_build_dirtcl.sh -b 32

The script build/hbb_build_packages.sh can be used to compile and install several
packages in the dirtcl built earlier.

Installation manual
-------------------
makedirtcl.tcl is a Tcl script, and only needs a relatively recent version of Tcl (>=8.4).
Running the script will install a dirtcl in the current directory (which must be empty)
The Tcl and Tk sources (default 8.5.19) must be installed next to the dirtcl
(../tcl8.5.19, ../tk8.5.19).
These sources will be patched, so do not mix with regular installs.

mkdir dirtcl
cd dirtcl
~/dev/dirtcl/makedirtcl.tcl 

You can give several options:
 --enable-threads or --disable-threads : create a thread enabled version of Tcl or not
 --version : use to compile a different version of Tcl (The patching 
             happens intelligently, but large changes between versions 
             are not necesarily coped with)
 --host and --build: for crosscompiling

Bugs
----
If you are having problems with the program contact me. I will
do my best to get it fixed. Please report any bugs you have
found. If possible, state your machine's hardware and software
configurations. Sending me a full description of the
circumstances in which the bug occurs, possibly with the data it
happened on, will help me tracking down a bug. If you have any
suggestions, you can also make them to me.

How to contact me
-----------------
I will do my best to reply as fast as I can to any problems, etc.
However, unfortunately the development of dirtcl is not my only task,
which is why my response might not be always as fast as you would
like.

Peter De Rijk
University of Antwerp (UA)
Department of Biochemistry
Universiteitsplein 1
B-2610 Antwerp

tel.: 32-03-820.23.27
E-mail: Peter.DeRijk@gmail.com

Legalities
----------
dirtcl is Copyright Peter De Rijk, VIB/University of Antwerp, 2012

following terms apply to all files associated with the software unless
explicitly disclaimed in individual files.

The author hereby grant permission to use, copy, modify, distribute, and
license this software and its documentation for any purpose, provided that
existing copyright notices are retained in all copies and that this notice
is included verbatim in any distributions. No written agreement, license, or
royalty fee is required for any of the authorized uses. Modifications to
this software may be copyrighted by their authors and need not follow the
licensing terms described here, provided that the new terms are clearly
indicated on the first page of each file where they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. THIS SOFTWARE IS
PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO
OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.
