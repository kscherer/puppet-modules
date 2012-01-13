#
class puppet::storeconfigs::mysql (
  $dbuser                 = $puppet::params::storeconfigs_dbuser,
  $dbpassword             = $puppet::params::storeconfigs_dbpassword,
  $mysql_root_pw          = $puppet::params::mysql_root_pw,
  $mysql_package_provider = $puppet::params::mysql_package_provider,
  $ruby_mysql_package     = $puppet::params::ruby_mysql_package,
  $activerecord_provider  = $puppet::params::activerecord_provider,
  $activerecord_package   = $puppet::params::activerecord_package,
  $activerecord_ensure    = $puppet::params::activerecord_ensure
  ) inherits puppet::params {

  if ! defined(Class['::mysql']) {
    class { '::mysql': }
    class { '::mysql::server': config_hash => { 'root_password' => $mysql_root_pw } }
    class { '::mysql::ruby':
      package_provider => $mysql_package_provider,
      package_name     => $ruby_mysql_package,
    }
  }

  Class['::mysql']
  -> Class['::mysql::ruby']
  -> Class['::mysql::server']
  -> Mysql::DB['puppet']

  mysql::db { 'puppet':
    user     => $dbuser,
    password => $dbpassword,
    charset  => 'utf8',
    host     => 'localhost',
    grant    => 'all',
  }

  #stored configs on 2.7.x requires activerecord gem version 3.0.11. Version 3.1
  #does not work. See http://projects.puppetlabs.com/issues/9304
  if ! defined(Package[$activerecord_package]) {
    package {
      $activerecord_package:
        ensure   => $activerecord_ensure,
        provider => $activerecord_provider,
    }
  }
}
