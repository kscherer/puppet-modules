#
class debian::foreman {
  apt::key {
    'foreman_apt_key':
      key        => '7059542D5AEA367F78732D02B3484CB71AA043B8',
      key_source => 'http://deb.theforeman.org/pubkey.gpg',
      notify     => Exec['apt_update'];
  }

  apt::source {
    'foreman':
      location    => 'http://deb.theforeman.org/',
      release     => $::lsbdistcodename,
      include_src => false,
      repos       => '1.7',
      require     => Apt::Key['foreman_apt_key'];
    'foreman-plugins':
      location    => 'http://deb.theforeman.org/',
      release     => 'plugins',
      include_src => false,
      repos       => '1.7',
      require     => Apt::Key['foreman_apt_key'];
  }
}
