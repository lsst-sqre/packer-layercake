#!/bin/bash

set -e

bootstrap_scl() {
  yum clean all -y
  yum install -y centos-release-scl
  yum clean all -y
}

install_devtoolset() {
  local scl=${1?scl is required}

  yum install -y \
    "${scl}-gcc" \
    "${scl}-gcc-c++" \
    "${scl}-gcc-gfortran"
}

install_scl() {
  local scl=${1?scl is required}

  yum install -y "$scl"
}

case ${SCL_COMPILER?scl compiler string is required} in
  devtoolset*)
    bootstrap_scl
    install_devtoolset "$SCL_COMPILER"
    ;;
  llvm-toolset*)
    bootstrap_scl
    install_scl "$SCL_COMPILER"
    ;;
  *)
    >&2 echo "unsupported scl compiler: ${SCL_COMPILER}"
    exit 1
    ;;
esac

# enable devtoolset by default
echo ". /opt/rh/${SCL_COMPILER}/enable" > "/etc/profile.d/${SCL_COMPILER}.sh"

# vim: tabstop=2 shiftwidth=2 noexpandtab
