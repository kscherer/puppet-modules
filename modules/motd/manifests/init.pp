# class to setup basic motd, include on all nodes
class motd {
  case $::operatingsystem {
    'Debian' : { $motd = '/etc/motd.tail' }
    default  : { $motd = '/etc/motd' }
  }

  #Ubuntu uses a special update-motd script
  if $::operatingsystem == 'Ubuntu' {
    file {
      '/etc/update-motd.d/55-windriver':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0755',
        content => template('motd/motd.erb');
      '/etc/motd':
        ensure => link,
        target => '/var/run/motd.dynamic';
    }
  } else {
    concat{
      $motd:
        owner => root,
        group => root,
        mode  => '0644';
    }

    concat::fragment{
      'motd_header':
        target  => $motd,
        content => template('motd/motd.erb'),
        order   => '01';
    }
  }
}
