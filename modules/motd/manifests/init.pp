# class to setup basic motd, include on all nodes
class motd {
  include concat::setup

  case $::operatingsystem {
    'Ubuntu' : { $motd = '/etc/update-motd.d/50windriver' }
    'Debian' : { $motd = '/etc/motd.tail' }
    default  : { $motd = '/etc/motd' }
  }

  concat{$motd:
    owner => root,
    group => root,
    mode  => 644
  }

  concat::fragment{'motd_header':
    target  => $motd,
    content => template('motd/motd.erb'),
    order   => 01,
  }
}
