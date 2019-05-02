include ::stdlib
include ::augeas
include ::wget

if $::osfamily == 'RedHat' {
  include ::epel
  Class['::epel'] -> Package<| provider == 'yum' |>
  Class['::epel'] -> Class['::lsststack']
}

class { '::lsststack':
  install_dependencies => true,
  install_convenience  => true,
  manage_repos         => false,
}
