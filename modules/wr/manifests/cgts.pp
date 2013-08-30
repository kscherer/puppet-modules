class wr::cgts {
  class { 'wr::common': }
  -> class { 'wr::mcollective': }

  include puppet
  include sudo
  include debian
  include nis
  include yocto

}
