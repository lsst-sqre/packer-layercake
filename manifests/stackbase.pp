include ::stdlib
include ::augeas
include ::sysstat
include ::wget

if $::osfamily == 'RedHat' {
  include ::epel
  Class['epel'] -> Package<| provider == 'yum' |>
}

class { '::lsststack':
  install_dependencies => true,
  install_convenience  => true,
  manage_repos         => false,
}
