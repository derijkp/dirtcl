You can use the cross-compat files the following way (example for i686-gcc-4.1.0-glibc-2.3.2)

# cross-compile using configure from autotools (will call i686-unknown-linux-gnu-gcc, etc.)
# This is based on tools in $CROSSNBASE, that are postfixed with target architecture
# the dir containing them is appended to the path
# load definitions
. /opt/crosstool/cross-compat-i686-gcc-4.1.0-glibc-2.3.2.sh
# configure and make
make distclean
../configure --host=$HOST --build=i386-linux
make

# generic cross-compile for simple makefiles (can of course also be used with configure, ...)
# This is based on tools in $CROSSNBASE, that are not postfixed with target, must be in path before rest.
. /opt/crosstool/cross-compat-i686-gcc-4.1.0-glibc-2.3.2.sh
PATH=$CROSSNBIN:$PATH make
