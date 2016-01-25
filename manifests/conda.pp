include ::stdlib

$stack_user  = $::lsst_stack_user ? {
  undef   => 'conda',
  default => $::lsst_stack_user,
}
$stack_group = $stack_user

$wheel_group = $::osfamily ? {
  'Debian' => 'sudo',
  default  => 'wheel',
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

# puppet-lsststack does not currently support el5
# this list of packages works with el5 *only*
# note that
# * e2fsprogs-devel provides uuid.h
# * perl-ExtUtils-MakeMaker does not exist / is not required as
#   ExtUtils::MakeMaker is bundled with perl
# * git is only provided by epel5
# * libcurl-devel is named curl-devel
# * java 1.8.0 is not available
package {[
  'bison',
  'curl',
  'blas',
  'bzip2-devel',
  'bzip2',
  'flex',
  'fontconfig',
  'freetype-devel',
  'gcc-c++',
  'gcc-gfortran',
  'libXext',
  'libXrender',
  'libXt-devel',
  'make',
  'openssl-devel',
  'patch',
  'perl',
  'readline-devel',
  'tar',
  'zlib-devel',
  'ncurses-devel',
  'cmake',
  'glib2-devel',
  'java-1.7.0-openjdk',
  'gettext',
  'curl-devel',
  'git',
  'e2fsprogs-devel',
]:
  ensure  => present,
  require =>  Class['epel'],
}
