#!/bin/sh -eux

sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo /usr/sbin/groupadd --system dockerroot || true
sudo chgrp dockerroot /var/run/docker.sock
sudo /usr/sbin/usermod --append --groups dockerroot "$USER"

# This line needs to be inserted into the docker service file in the [Service]
# section to make the docker.sock permissions persistent across reboots
#
# [Service]
# ...
# ExecStartPost=/usr/bin/chown root:dockerroot /var/run/docker.sock
#

sudo yum install -y augeas
sudo augtool <<'END'
set /files/lib/systemd/system/docker.service/Service/ExecStartPost/command "/usr/bin/chown"
set /files/lib/systemd/system/docker.service/Service/ExecStartPost/arguments/1 "root:dockerroot"
set /files/lib/systemd/system/docker.service/Service/ExecStartPost/arguments/2 "/var/run/docker.sock"
save
END
