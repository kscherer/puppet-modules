# class to setup basic motd, include on all nodes
class motd {
  concat{
    '/etc/motd':
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
