#!/bin/bash

set -e

VER=${DEVTOOLSET_VERSION?devtoolset version is required}

yum clean all -y
yum install -y centos-release-scl
yum install -y \
    "devtoolset-${VER}-gcc" \
    "devtoolset-${VER}-gcc-c++" \
    "devtoolset-${VER}-gcc-gfortran"

# enable devtoolset by default
echo ". /opt/rh/devtoolset-${VER}/enable" > "/etc/profile.d/devtoolset-${VER}.sh"
