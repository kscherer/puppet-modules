# Define the default puppet master setup for WindRiver

class wr::master {

  Class['redhat']
  -> Class['wr::mcollective']
  -> Class['mysql']
  -> Class['mysql::ruby']
  -> Class['wr::master']

  include apache
  include apache::mod::passenger

  include wr::mcollective

  #choose a hierachy from most specific to least specific
  class {
    'hiera':
      hierarchy  => [ 'nodes/%{hostname}',
                      '%{location}',
                      '%{operatingsystem}-%{lsbmajdistrelease}-%{architecture}',
                      '%{operatingsystem}-%{lsbmajdistrelease}',
                      '%{osfamily}',
                      'common' ],
      hiera_yaml => '/etc/puppet/hiera.yaml',
      datadir    => '/etc/puppet/environments/%{environment}/hiera',
      logger     => 'puppet',
      backends   => ['yaml'],
  }

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
      dashboard                   => true,
      dashboard_passenger         => true,
      dashboard_port              => '3000',
      dashboard_password          => 'dashb0ard',
      storeconfigs                => true,
      storeconfigs_dbadapter      => 'puppetdb',
      mysql_root_pw               => 'r00t', #needed for dashboard
      require                     => [ Yumrepo['puppetlabs'],
                                      Yumrepo['passenger']],
  }

  file {
    'puppet_env':
      ensure => directory,
      path   => '/etc/puppet/environments',
      owner  => 'puppet',
      group  => 'puppet';
  }

  cron {
    'report_clean':
      command => '/usr/bin/find /var/lib/puppet/reports -ctime +7 -name \'*.yaml\' -exec rm {} \; &> /dev/null',
      user    => 'puppet',
      minute  => '0',
      hour    => '2';
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
      #this command uses SSL to connect to puppet, but returns "Bad Request"
      #which is all that we need to confirm service is actually running
      check_command       => "check_http!-I ${::ipaddress} -S -p 8140 -e HTTP",
      notification_period => 'workhours',
      contact_groups      => 'admins';
  }
}
