#
class xylo {

  # git is a must install
  include git

  #make sure git is installed before this class starts to create repos
  Class['git'] -> Class['xylo']

  ssh_authorized_key {
    'buildadmin@pek-blade17':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('buildadmin@pek-blade17'),
      type   => 'ssh-dss';
  }

  File {
    owner   => 'buildadmin',
    group   => 'buildadmin',
  }

  file {
    '/home/buildadmin/.gitconfig':
      mode    => '0644',
      source  => 'puppet:///modules/nx/gitconfig';
    '/home/buildadmin/.history':
      ensure => directory,
      mode   => '0700';
    '/home/buildadmin/.ssh/id_dsa.pub':
      ensure => absent;
    '/home/buildadmin/.ssh/id_dsa':
      ensure => absent;
    '/home/buildadmin/.ssh/config':
      ensure => present,
      mode   => '0600',
      source => 'puppet:///modules/nx/ssh_config';
    '/home/buildadmin/.bashrc':
      ensure => present,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/buildadmin/.aliases':
      ensure => present,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/buildadmin/.bash_profile':
      ensure  => present,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
    '/home/buildadmin/.screenrc':
      ensure => present,
      source => 'puppet:///modules/xylo/screenrc';
  }

  case $::hostname {
    /^pek-blade17.*/:     { include xylo::master }
    /^pek-blade(18|19|20|21).*/: { include xylo::slave }
    default:           { fail("Unsupported xylo configuration for ${::hostname}") }
  }

  if $::osfamily == 'RedHat' {
    ensure_resource('package', 'vim-enhanced', {'ensure' => 'installed' })
  }
}
