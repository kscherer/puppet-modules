# class to setup basic motd, include on all nodes
class motd {
  $motd = '/etc/motd'
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
