#
class wr::common {

  #Create standard base motd
  include motd
  include ntp
  include wr::common::ssh_root_keys
  include wr::common::etc_host_setup
  include wr::workaround::xen

  $puppet_version = 'latest'

  #The puppet package get handled by puppet module, but not facter
  package {
    'facter':
      ensure   => 'latest';
  }

  #set the puppet server based on hostname
  $puppet_server = hiera('puppet_server')

  #add my configs to all machines
  file {
    '/root/.bashrc':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/root/.aliases':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/root/.bash_profile':
      ensure  => present,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }
}
