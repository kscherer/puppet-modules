# Define the default puppet master setup for WindRiver

class wr::master {

  Class['mysql']
  -> Class['mysql::ruby']
  -> Class['wr::master']

  include apache
  include apache::mod::passenger

  include wr::mcollective

  include hiera

  class { 'puppetdb':
    open_ssl_listen_port => false,
    open_postgres_port   => false,
  }
  -> class {
    'puppetdb::master::config':
      puppetdb_server     => hiera('puppet::puppet_server'),
      manage_storeconfigs => false,
      restart_puppet      => false,
  }

  class {
    'puppet':
      agent                       => true,
      puppet_master_ensure        => 'latest',
      master                      => true,
      autosign                    => true,
      manifest                    => '$confdir/environments/$environment/manifests/site.pp',
      modulepath                  => '$confdir/environments/$environment/modules',
      puppet_passenger            => true,
      passenger_package           => 'mod_passenger',
      passenger_ensure            => 'present',
      dashboard                   => false,
      storeconfigs                => true,
      storeconfigs_dbadapter      => 'puppetdb',
      mysql_root_pw               => 'r00t', #needed for dashboard
      require                     => [ Yumrepo['puppetlabs'],
                                      Yumrepo['passenger']],
  }

  cron {
    'clean_dashboard':
      command => 'cd /usr/share/puppet-dashboard; rake RAILS_ENV=production reports:prune upto=1 unit=wk &> /dev/null',
      minute  => '0',
      hour    => '2';
    'optimize_dashboard':
      command => 'cd /usr/share/puppet-dashboard; rake RAILS_ENV=production db:raw:optimize &> /dev/null',
      minute  => '0',
      hour    => '3',
      weekday => '0';
  }

  @@nagios_service {
    'puppet_check':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'puppet_check',
      #this command attempts to retrieve puppetmaster ca cert. If that
      #doesn't work then nothing else can work
      check_command       => "check_http!-I ${::ipaddress} -p 8140 -u /certificate/ca --header='Accept: s' -e 'DOCTYPE'",
      notification_period => 'workhours',
      contact_groups      => 'admins';
  }
}
