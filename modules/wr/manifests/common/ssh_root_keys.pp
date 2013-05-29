#
class wr::common::ssh_root_keys {
  ssh_authorized_key {
    'kscherer_windriver':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('kscherer@yow-kscherer-l1'),
      type   => 'ssh-dss';
    'kscherer_home':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('kscherer@helix'),
      type   => 'ssh-rsa';
    'jch_laptop':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('jch@jch-schlepp.honig.net'),
      type   => 'ssh-rsa';
    'jch_server':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('jch@kismet.honig.net'),
      type   => 'ssh-rsa';
  }
}
