#
class wr::common::ssh_root_keys {
  ssh_authorized_key {
    'kscherer_desktop':
      ensure => 'present',
      user   => 'root',
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    'kscherer_home':
      ensure => 'present',
      user   => 'root',
      key    => hiera('kscherer@helix'),
      type   => 'ssh-rsa';
    'kscherer_laptop':
      ensure => 'present',
      user   => 'root',
      key    => hiera('kscherer@yow-kscherer-l1'),
      type   => 'ssh-rsa';
    'jch_laptop':
      ensure => 'present',
      user   => 'root',
      key    => hiera('jch@jch-schlepp.honig.net'),
      type   => 'ssh-rsa';
    'jch_server':
      ensure => 'present',
      user   => 'root',
      key    => hiera('jch@kismet.honig.net'),
      type   => 'ssh-rsa';
    'pkennedy_home':
      ensure => 'present',
      user   => 'root',
      key    => hiera('pkennedy@pkennedy-linux.site'),
      type   => 'ssh-rsa';
  }

  # ssh public key auth does not work if home directory is not locked down
  file {
    '/root':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0700';
  }
}
