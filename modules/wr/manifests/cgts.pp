class wr::cgts {
  class { 'wr::common': }
  -> class { 'wr::mcollective': }

  include puppet
  include debian
  include nis
  include yocto
  include nrpe

  include sudo
  sudo::conf {
    'cgts':
      source  => 'puppet:///modules/wr/sudoers.d/cgts';
  }
}
