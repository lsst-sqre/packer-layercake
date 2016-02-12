#!/bin/bash -eux

# this has apparently become a dir
rm -rf /etc/udev/rules.d/70-persistent-net.rules;
yum -y clean all

# cleanup centos user account (if it exists)
if id -u centos > /dev/null 2>&1; then
    # and we are not currently logged in as the centos user...
    if [[ $(id -u -n) == 'centos' ]]; then
        /usr/sbin/userdel -r centos
    fi
fi

# cleanup any ssh keys nova/cloud-init may have injected
rm -rf /root/.ssh
find  /home/ -maxdepth 2 -type d -name .ssh -exec rm -rf {} \;

# per https://aws.amazon.com/articles/0155828273219400
find /root/.*history /home/*/.*history -exec rm -f {} \; || true
find /home/*/.*ssh -name "authorized_keys" -exec rm -f {} \; || true

# cleanup any junk left under /tmp & /var/tmp
find /tmp /var/tmp -mindepth 1 -maxdepth 1 -print0 | xargs -0 rm -rf
