dirtcl
====== Tool to create a directory based, standalone/isolated version of tcl
       Copyright Peter De Rijk (UA)

Application directories
-----------------------
The goal of an application directory is to distribute a self-contained application, 
with most of its dependencies in one directory. Everything needed to run
the application is in one directory: installation is as simple as moving
the directory to the place you want it (unpacking it, if it is compressed).
Uninstallation is done by removing the directory.
The application executable must stay in the application directory to work.
If you want to be able to start it from another location (desktop, bin),
make a link to it.

dirtcl
------
makedirtcl.tcl will make a selfcontained Tcl/Tk distribution (dirtcl), that 
can be used to create a Tcl/Tk based application directory.
It will compile a customized version of Tcl and Tk, that can exist next to 
different versions with different sets of extensions without interference, not
from a system installed version, nor from other dirtcls.

The tclsh in a dirtcl will not look in the usual places for extension packages, nor will
it honor the TCLLIBPATH environment variable. Typical extensions will only be searched in the 
subdirectory pkgs of dirtcl. Of course you can extend the search as usual by added directories to 
the auto_path variable.

A special kind of extension packages can be installed in the exts directory. These will be searched 
by name of the directory in stead of using a pkgIndex.tcl. They must contain a file init.tcl, that 
will be used to initiate the package upon a package require

If the tclsh executable in a dirtcl has a name different from tclsh or wish (by renameing or 
copying, or, in Linux, a softlink made to it that is also in the dirtcl directory), an application
will be started instead of the plain tclsh. The application code must be in the directory name apps.
e.g. The "demo" executable that is by default installed in the dirtcl, will actually start tcl, and
run the file apps/demos/demos.tcl in the dirtcl. There can be more than one app in a dirtcl.

The dirtcl tclsh defines some global variables
 - tcl_dirtcl: the dirtcl directory name
 - dirtcl: set to 1 (exists in a dirtcl)
 - app_base: base name of the tclsh executable used to start dirtcl
 - app_version: version part of the tclsh executable used to start dirtcl

System requirements and Installation
------------------------------------
makedirtcl.tcl is a Tcl script, and only needs a relatively recent version of Tcl (>=8.4).
Running the script will install a dirtcl in the current directory (which must be empty)
The Tcl and Tk sources (default 8.5.10) must be installed next to the dirtcl
(../tcl8.5.10, ../tk8.5.10).
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
RnaViz is Copyright Peter De Rijk, University of Antwerp (UA), 2012

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
