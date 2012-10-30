

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

  class { 'debian': }
  -> class { 'ntp':
    servers    => $wr::common::ntp_servers,
  }
  -> class { 'nis': }
  -> class { 'yocto': }
}
