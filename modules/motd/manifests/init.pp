# class to setup basic motd, include on all nodes
class motd {
  case $::operatingsystem {
    'Debian' : { $motd = '/etc/motd.tail' }
    'Ubuntu' : { $motd = '/etc/update-motd.d/55-windriver' }
    default  : { $motd = '/etc/motd' }
  }

  #Ubuntu uses a special update-motd script
  if $::operatingsystem == 'Ubuntu' {
    file {
      '/etc/motd':
        ensure => absent;
    }
  }
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
