#!/bin/bash
set -e

echo "install-deps.sh"
yum install -y yum-plugin-ovl
yum install -y libX11-devel wget sudo
echo "done"
