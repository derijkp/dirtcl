#!/bin/bash
set -e

echo "install-deps.sh"

# centos 6 is EOL, moved to vault: (hbb v2.2.0 already solves this)

yum install -y libX11-devel wget sudo
yum install -y git gcc-c++
yum install -y centos-release-scl
yum upgrade -y
yum install -y devtoolset-8
# you can now use
# scl enable devtoolset-8 bash
# to develop with a newer toolset
echo "done"
