#!/bin/bash
set -e

echo "install-deps.sh"
## centos 6 is EOL, moved to vault: adapt the repos
cd
echo '
[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=i386&repo=os&infra=$infra
baseurl=http://vault.centos.org/centos/$releasever/os/i386/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#released updates
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=i386&repo=updates&infra=$infra
baseurl=http://vault.centos.org/centos/$releasever/updates/i386/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=i386&repo=extras&infra=$infra
baseurl=http://vault.centos.org/centos/$releasever/extras/i386/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=i386&repo=centosplus&infra=$infra
baseurl=http://vault.centos.org/centos/$releasever/centosplus/i386/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=i386&repo=contrib&infra=$infra
baseurl=http://vault.centos.org/centos/$releasever/contrib/i386/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
' > temp
mv temp /etc/yum.repos.d/CentOS-Base.repo

yum install -y yum-plugin-ovl
yum install -y libX11-devel wget sudo
yum install -y git gcc-c++
yum install -y centos-release-scl
yum upgrade -y
yum install -y devtoolset-8
# you can now use
# scl enable devtoolset-8 bash
# to develop with a newer toolset
echo "done"
