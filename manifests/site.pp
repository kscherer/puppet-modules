# The site file for the puppet master server
$extlookup_datadir = "/etc/puppet/environments/${environment}/extdata/"
$extlookup_precedence = [ '%{fqdn}', 'package', 'common']

#set the default path for all exec resources
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

filebucket {
  'main':
    path   => false
}
File { backup => main }

if versioncmp($::puppetversion,'3.6.1') >= 0 {
  # Kill deprecation warnings in Puppet 3.6+
  Package { allow_virtual => true }
}

#force the provider on Suse to be zypper
if $::osfamily == 'Suse' {
  Package { provider => zypper }
}

case $::location {
  undef: {
    #This path is used for stdlib facter_dot_d module
    #if location fact is not set by pluginsync, use default from puppet server used
    $location = regsubst($::hostname, '^(\w\w\w).*','\1')
    notice("Using calculated location of ${::location}")
    file {
      '/etc/facter/':
        ensure => directory;
      '/etc/facter/facts.d/':
        ensure => directory;
      '/etc/facter/facts.d/location.txt':
        ensure  => present,
        content => inline_template( 'location=<%= @servername[0..2] %>' );
      '/etc/facter/facts.d/homedir_users.yaml':
        ensure => present,
        source => 'puppet:///modules/wr/homedir_users.yaml';
    }
  }
  default: { } #location properly set, Nothing to do
}
