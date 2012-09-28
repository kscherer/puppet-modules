

$extlookup_datadir = '/puppet/extdata/'
$extlookup_precedence = [ 'common']

case $::location {
  undef: {

    #This path is used for stdlib facter_dot_d module
    #This makes sure that if location is not set, make sure
    #the default one is ready
    file {
      '/etc/facter/':
        ensure => directory;
      '/etc/facter/facts.d/':
        ensure => directory;
      '/etc/facter/facts.d/location.txt':
        ensure  => present,
        content => inline_template( 'location=<%= hostname[0..2] %>' );
    }
    $location = regsubst($::hostname, '^(\w\w\w).*','\1')
    notice("Using calculated location of ${::location}")
  }
  default: { } #location properly set, Nothing to do
}

node default {

  case $::operatingsystem {
    Debian,Ubuntu: { $base_class='debian' }
    CentOS,RedHat,Fedora: { $base_class='redhat' }
    OpenSuSE,SLED: { $base_class='suse'}
    default: { fail("Unsupported OS: ${::operatingsystem}")}
  }

  class { $base_class: }
  -> class {
    'wr::mcollective':
      client       => true,
      registration => false,
  }
  -> class { 'ntp':
    servers    => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }

  #vagrant uses puppet apply which needs hiera packages installed
  Class[$base_class] -> package{ ['hiera','hiera-puppet']: ensure => installed; }
}
