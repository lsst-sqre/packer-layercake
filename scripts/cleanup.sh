#!/bin/sh -eux

rm -f /etc/udev/rules.d/70-persistent-net.rules;
yum -y clean all

# cleanup centos user account (if it exists)
if id -u centos > /dev/null 2>&1; then
    /usr/sbin/userdel -r centos
fi

# cleanup any ssh keys nova/cloud-init may have injected
rm -rf /root/.ssh
find  /home/ -maxdepth 2 -type d -name .ssh -exec rm -rf {} \;
