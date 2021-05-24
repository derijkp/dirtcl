#!/bin/bash
set -e

#echo "i386" > /etc/yum/vars/basearch
#echo "i686" > /etc/yum/vars/arch
#python -c 'import yum, json; yb = yum.YumBase(); print json.dumps(yb.conf.yumvar, indent=2)'


echo "install-deps.sh"

# if you want/need to check the settings used by yum
# python -c 'import yum, json; yb = yum.YumBase(); print json.dumps(yb.conf.yumvar, indent=2)'
 
# phusion_centos-6-scl-i386 packages are gone, no longer supports i386
rm /etc/yum.repos.d/phusion_centos-6-scl-i386.repo
yum upgrade --nogpgcheck -y

yum install -y libX11-devel wget sudo
yum install -y git gcc-c++
yum install -y yum-plugin-ovl
yum upgrade -y
echo "done"
