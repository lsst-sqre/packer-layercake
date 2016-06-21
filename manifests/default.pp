include ::stdlib
include ::augeas
include ::sysstat
include ::wget

$stack_user  = $::lsst_stack_user ? {
  #undef   => 'lsstsw',
  undef   => 'vagrant',
  default => $::lsst_stack_user,
}
$stack_group = $stack_user

$wheel_group = $::osfamily ? {
  'Debian' => 'sudo',
  default  => 'wheel',
}

class { 'sudo':
  purge               => false,
  config_file_replace => false,
}
sudo::conf { 'wheel':
  content  => '%wheel ALL=(ALL) NOPASSWD: ALL',
}

if $::osfamily == 'RedHat' {
  include ::epel
  Class['epel'] -> Package<| provider == 'yum' |>
}

user { $stack_user:
  ensure     => present,
  gid        => $stack_group,
  groups     => [$wheel_group],
  managehome => true,
}

group { $stack_group:
  ensure => present,
}

class { '::lsststack':
  install_convenience => true,
}

# prune off the destination dir so ::lsststack::newinstall may declare it
$dirtree = dirtree($lsst_stack_path)
$d = delete_at($dirtree, -1) # XXX replace with array slice nder puppet 4.x
ensure_resource('file', $d, {'ensure' => 'directory'})

::lsststack::newinstall { $stack_user:
  user         => $stack_user,
  manage_user  => false,
  group        => $stack_group,
  manage_group => false,
  stack_path   => $::lsst_stack_path,
}
