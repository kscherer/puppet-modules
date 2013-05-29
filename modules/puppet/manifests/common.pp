#
class puppet::common {

  user { 'puppet':
    ensure => present,
    gid    => 'puppet',
  }

  group { 'puppet':
    ensure => present,
  }

  if ! defined(File['/etc/puppet']) {
    file { '/etc/puppet':
      ensure       => directory,
      group        => 'puppet',
      owner        => 'puppet',
      recurse      => true,
      recurselimit => '1',
    }
  }

  include concat::setup

  concat {
    '/etc/puppet/puppet.conf':
      owner => 'puppet',
      group => 'puppet',
      mode  => '0644',
  }

  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/puppet.conf-common.erb'),
  }
}
