# Class: mcollective::server::package::redhat
#
#   This class installs MCollective dependency packages for Redhat.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::package::suse(
  $version ) {

  package { 'mcollective':
    ensure => $version,
  }

}

