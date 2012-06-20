# class to setup basic motd, include on all nodes
class motd {
  include concat::setup
  $motd = '/etc/motd'

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

  # local users on the machine can append to motd by just creating
  # /etc/motd.local
  concat::fragment{'motd_local':
    ensure  => '/etc/motd.local',
    target  => $motd,
    order   => 15
  }
}
