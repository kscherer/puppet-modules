# A wrapper around official docker module
# Most of this code will go away once garethr docker module supports
# new upstream packages
class profile::docker {

  # Use local docker mirror created using apt-mirror
  apt::source {
    'wr-docker':
      location     => "http://${::location}-mirror.wrs.com/mirror/apt/apt.dockerproject.org/repo/",
      release      => "ubuntu-${::lsbdistcodename}",
      repos        => 'main',
      architecture => 'amd64',
      include_src  => false,
      key          => '58118E89F3A912897C070ADBF76221572C52609D',
      key_server   => 'hkp://pgp.mit.edu:80';
  }

  package {
    'docker-engine':
      ensure  => 'present';
  }
  Apt::Source['wr-docker'] -> Package['docker-engine']

  include ::docker
}
