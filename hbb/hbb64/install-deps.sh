#!/bin/bash
set -e

echo "install-deps.sh"

# centos 6 is EOL, moved to vault: adapt the repos (hbb v2.2.0 does this)
if ! cat /etc/yum.repos.d/CentOS-Base.repo | grep --quiet vault; then
	echo "change repos to vault"
	curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo
	curl https://www.getpagespeed.com/files/centos6-epel-eol.repo --output /etc/yum.repos.d/epel.repo
	curl https://www.getpagespeed.com/files/centos6-scl-eol.repo --output /etc/yum.repos.d/CentOS-SCLo-scl.repo
	curl https://www.getpagespeed.com/files/centos6-scl-rh-eol.repo --output /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
fi
yum upgrade --nogpgcheck -y

yum install -y libX11-devel wget sudo
yum install -y git gcc-c++
yum install -y centos-release-scl
yum upgrade -y
yum install -y devtoolset-8
# you can now use
# scl enable devtoolset-8 bash
# to develop with a newer toolset
echo "done"
