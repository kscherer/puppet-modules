# Class: puppet::storedconfiguration
#
# This class installs and configures Puppet's stored configuration capability
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::storeconfigs (
  $storeconfigs           = true,
  $thinstoreconfigs       = false,
  $dbadapter              = $puppet::params::storeconfigs_dbadapter,
  $dbuser                 = $puppet::params::storeconfigs_dbuser,
  $dbpassword             = $puppet::params::storeconfigs_dbpassword,
  $dbserver               = $puppet::params::storeconfigs_dbserver,
  $dbsocket               = $puppet::params::storeconfigs_dbsocket,
  $mysql_root_pw          = $puppet::params::mysql_root_pw,
  $mysql_package_provider = $puppet::params::mysql_package_provider,
  $ruby_mysql_package     = $puppet::params::ruby_mysql_package,
  $activerecord_provider  = $puppet::params::activerecord_provider,
  $activerecord_package   = $puppet::params::activerecord_package,
  $activerecord_ensure    = $puppet::params::activerecord_ensure
) inherits puppet::params {

  case $dbadapter {
    'sqlite3': {
      include puppet::storeconfig::sqlite
    }
    'mysql': {
      class {
        "puppet::storeconfigs::mysql":
          dbuser                 => $dbuser,
          dbpassword             => $dbpassword,
          mysql_root_pw          => $mysql_root_pw,
          mysql_package_provider => $mysql_package_provider,
          ruby_mysql_package     => $ruby_mysql_package,
          activerecord_provider  => $activerecord_provider,
          activerecord_package   => $activerecord_package,
          activerecord_ensure    => $activerecord_ensure,
      }
    }
    default: { err("target dbadapter $dbadapter not implemented") }
  }

  concat::fragment { 'puppet.conf-master-storeconfig':
    order   => '06',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master-storeconfigs.erb");
  }

}

