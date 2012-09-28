# The site file for the puppet master server
$extlookup_datadir = "/etc/puppet/environments/${environment}/extdata/"
$extlookup_precedence = [ '%{fqdn}', 'package', 'common']

#set the default path for all exec resources
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

# Define the bucket
filebucket {
  'main':
    server => $::server, path => false
}

# Specify it as the default target
File { backup => main }

#force the provider on RH 4 to be yum, not uptodate
if $::operatingsystem == 'RedHat' and $::operatingsystemrelease == '4' {
  Package { provider => yum }
}

#force the provider on Suse to be zypper
if $::osfamily == 'Suse' {
  Package { provider => zypper }
}

case $::location {
  undef: {
    #This path is used for stdlib facter_dot_d module
    #if location fact is not set by pluginsync, use default from hostname
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

# define nodes
import 'nodes.pp'
