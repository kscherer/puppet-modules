# Class: puppet::master
#
# This class installs and configures a Puppet master
#
# Parameters:
#   [*modulepath*]            - The modulepath configuration value used in
#                               puppet.conf
#   [*confdir*]               - The confdir configuration value in puppet.conf
#   [*manifest*]              - The manifest configuration value in puppet.conf
#   [*storeconfigs*]          - Boolean determining whether storeconfigs is
#                               to be enabled.
#   [*thinstoreconfigs*]      - Should stored config be "thin"
#   [*storeconfigs_dbadapter*] - The database adapter to use with storeconfigs
#   [*storeconfigs_dbuser*]   - The database username used with storeconfigs
#   [*storeconfigs_dbpassword*] - The database password used with storeconfigs
#   [*storeconfigs_dbserver*]   - Fqdn of the storeconfigs database server
#   [*storeconfigs_dbsocket*]   - The path to the mysql socket file
#   [*certname*]              - The certname configuration value in puppet.conf
#   [*autosign*]              - The autosign configuration value in puppet.conf
#   [*dashboard_port*]          - The port on which puppet-dashboard should run
#   [*puppet_passenger*]      - Boolean value to determine whether puppet is
#                               to be run with Passenger
#   [*puppet_site*]           - The VirtualHost value used in the apache vhost
#                               configuration file when Passenger is enabled
#   [*puppet_docroot*]        - The DocumentRoot value used in the apache vhost
#                               configuration file when Passenger is enabled
#   [*puppet_vardir*]         - The path to the puppet vardir
#   [*puppet_passenger_port*] - The port on which puppet is listening when
#                               Passenger is enabled
#   [*puppet_master_package*]   - The name of the puppet master package
#   [*package_provider*]        - The provider used for package installation
#   [*puppet_master_ensure*]               - The value of the ensure parameter for the
#                               puppet master and agent packages
#   [*mysql_package_provider*] - The package provider to use when installing
#                               the ruby-mysql package
#   [*ruby_mysql_package*]     - The package name for the ruby-mysql package
#
# Actions:
#
# Requires:
#
#  Class['concat']
#  Class['stdlib']
#  Class['concat::setup']
#  Class['mysql'] (conditionally)
#  Class['passenger'] (conditionally)
#  Class['apache'] (conditionally)
#
# Sample Usage:
#
#  $modulepath = [
#    "/etc/puppet/modules/site",
#    "/etc/puppet/modules/dist",
#  ]
#
#  class { "puppet::master":
#    modulepath => inline_template("<%= modulepath.join(':') %>"),
#    dbadapter  => "mysql",
#    dbuser     => "puppet",
#    dbpassword => "password"
#    dbsocket   => "/var/run/mysqld/mysqld.sock",
#  }
#
class puppet::master (
  $modulepath              = $puppet::params::modulepath,
  $confdir                 = $puppet::params::confdir,
  $manifest                = $puppet::params::manifest,
  $storeconfigs            = false,
  $thinstoreconfigs        = false,
  $storeconfigs_dbadapter  = $puppet::params::storeconfigs_dbadapter,
  $storeconfigs_dbuser     = $puppet::params::storeconfigs_dbuser,
  $storeconfigs_dbpassword = $puppet::params::storeconfigs_dbpassword,
  $storeconfigs_dbserver   = $puppet::params::storeconfigs_dbserver,
  $storeconfigs_dbsocket   = $puppet::params::storeconfigs_dbsocket,
  $mysql_root_pw           = $puppet::params::mysql_root_pw,
  $mysql_package_provider  = undef,
  $ruby_mysql_package      = undef,
  $certname                = $puppet::params::certname,
  $autosign                = false,
  $dashboard_port          = UNSET,
  $puppet_passenger        = false,
  $puppet_site             = $puppet::params::puppet_site,
  $puppet_conf             = $puppet::params::puppet_conf,
  $puppet_docroot          = $puppet::params::puppet_docroot,
  $puppet_vardir           = $puppet::params::puppet_vardir,
  $puppet_ssldir           = $puppet::params::puppet_ssldir,
  $puppet_passenger_port   = $puppet::params::puppet_passenger_port,
  $puppet_master_package   = $puppet::params::puppet_master_package,
  $puppet_agent_name       = $puppet::params::puppet_agent_name,
  $puppet_server           = $puppet::params::puppet_server,
  $package_provider        = $puppet::params::package_provider,
  $passenger_ensure        = undef,
  $passenger_package       = undef,
  $puppet_master_service   = $puppet::params::puppet_master_service,
  $puppet_master_ensure    = 'present',
  $puppet_environment      = 'production',
  $activerecord_provider   = $puppet::params::activerecord_provider,
  $activerecord_package    = $puppet::params::activerecord_package,
  $activerecord_ensure     = $puppet::params::activerecord_ensure
) inherits puppet::params {

  #all files for the puppet master are owned by puppet user
  File {
    require => Package[$puppet_master_package],
    owner   => 'puppet',
    group   => 'puppet',
  }

  #except /var/lib/puppet/lib which is used by root for pluginsync
  #when running agent on master
  file {
    "${puppet_vardir}/lib":
      ensure  => directory,
      owner   => 'root',
      group   => 'root';
    "${puppet_vardir}/facts.d":
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
  }

  #the git stomp hooks create one directory per environment
  file {
    'puppet_env':
      ensure => directory,
      path   => '/etc/puppet/environments',
      owner  => 'puppet',
      group  => 'puppet';
  }

  if $storeconfigs {
    class { 'puppet::storeconfigs':
      storeconfigs           => $storeconfigs,
      thinstoreconfigs       => $thinstoreconfigs,
      dbadapter              => $storeconfigs_dbadapter,
      dbuser                 => $storeconfigs_dbuser,
      dbpassword             => $storeconfigs_dbpassword,
      dbserver               => $storeconfigs_dbserver,
      dbsocket               => $storeconfigs_dbsocket,
      mysql_root_pw          => $mysql_root_pw,
      mysql_package_provider => $mysql_package_provider,
      ruby_mysql_package     => $ruby_mysql_package,
      activerecord_provider  => $activerecord_provider,
      activerecord_package   => $activerecord_package,
      activerecord_ensure    => $activerecord_ensure,
    }

    #make sure database is installed before puppet.conf is written
    Class['puppet::storeconfigs']
    -> Concat::Fragment['puppet.conf-master']
  }

  if ! defined(Package[$puppet_master_package]) {
    package { $puppet_master_package:
      ensure   => $puppet_master_ensure,
      provider => $package_provider,
    }
  }

  if $puppet_passenger {

    #httpd service is setup in apache class
    $service_notify  = Service['httpd']

    Concat::Fragment['puppet.conf-master'] -> Service['httpd']

    Package[$passenger_package]
    -> Apache::Vhost["puppet-${puppet_site}"]

    include apache
    include apache::mod::passenger
    include apache::mod::headers

    apache::vhost {
      "puppet-${certname}":
        port               => $puppet_passenger_port,
        priority           => '40',
        docroot            => $puppet_docroot,
        servername         => $certname,
        ssl                => true,
        ssl_cert           => "${puppet_ssldir}/certs/${certname}.pem",
        ssl_key            => "${puppet_ssldir}/private_keys/${certname}.pem",
        ssl_chain          => "${puppet_ssldir}/ca/ca_crt.pem",
        ssl_ca             => "${puppet_ssldir}/ca/ca_crt.pem",
        ssl_crl            => "${puppet_ssldir}/ca/ca_crl.pem",
        rack_base_uris     => '/',
        custom_fragment    => template('puppet/apache_custom_fragment.erb'),
        require            => [ File['/etc/puppet/rack/config.ru'], File[$puppet_conf] ],
    }

    file {
      '/etc/puppet/rack':
        ensure => directory;
      '/etc/puppet/rack/tmp':
        ensure => directory;
      '/etc/puppet/rack/config.ru':
        ensure => present,
        source => 'puppet:///modules/puppet/config.ru',
        mode   => '0644';
    }

    concat::fragment { 'puppet.conf-master':
      order   => '05',
      target  => '/etc/puppet/puppet.conf',
      content => template('puppet/puppet.conf-master.erb'),
    }
  } else {

    concat::fragment { 'puppet.conf-master':
      order   => '05',
      target  => '/etc/puppet/puppet.conf',
      content => template('puppet/puppet.conf-master.erb'),
    }

    if $package_provider == 'gem' {

      $service_notify = Exec['puppet_master_start']

      exec { 'puppet_master_start':
        command   => '/usr/bin/nohup puppet master &',
        refresh   => '/usr/bin/pkill puppet && /usr/bin/nohup puppet master &',
        unless    => '/bin/ps -ef | grep -v grep | /bin/grep \'puppet master\'',
        require   => File['/etc/puppet/puppet.conf'],
        subscribe => [ Package[$puppet_master_package],
                      Concat::Fragment['puppet.conf-master']]
      }
    } else {
      $service_notify = Service[$puppet_master_service]

      service {
        $puppet_master_service:
          ensure    => running,
          enable    => true,
          hasstatus => true,
          require   => File['/etc/puppet/puppet.conf'],
          subscribe => [ Package[$puppet_master_package],
                        Concat::Fragment['puppet.conf-master']]
      }
    }
  }

  file { $puppet_vardir:
    ensure       => directory,
    recurse      => true,
    recurselimit => '1',
    notify       => $puppet::master::service_notify,
  }

  Package[$puppet_master_package] -> Concat[$puppet_conf] ~> $service_notify
  Package[$puppet_master_package] -> File['/etc/puppet'] ~> $service_notify

  cron {
    'report_clean':
      command => '/usr/bin/find /var/lib/puppet/reports -ctime +7 -name \'*.yaml\' -exec rm {} \; &> /dev/null',
      user    => 'puppet',
      minute  => '0',
      hour    => '2';
  }
}
