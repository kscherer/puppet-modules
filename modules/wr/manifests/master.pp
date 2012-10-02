# Define the default puppet master setup for WindRiver

class wr::master {

  Class['redhat']
  -> Class['wr::mcollective']
  -> Class['mysql']
  -> Class['mysql::ruby']
  -> Class['wr::master']

  class { 'wr::mcollective': client => true }

  class {
    'hiera':
      hierarchy  => [ '%{operatingsystem}-%{lsbmajdistrelease}-%{architecture}',
                      '%{operatingsystem}-%{lsbmajdistrelease}',
                      '%{osfamily}',
                      '%{location}',
                      'common' ],
      hiera_yaml => '/etc/puppet/hiera.yaml',
      datadir    => '/etc/puppet/environments/%{environment}/hiera',
      logger     => 'puppet',
      backends   => ['yaml'],
  }

  class { 'puppetdb':
    manage_redhat_firewall => false
  }
  -> class {
    'puppetdb::master::config':
      puppetdb_server     => $wr::common::puppet_server,
      manage_storeconfigs => false,
      restart_puppet      => false,
  }

  class {
    'puppet':
      agent                       => true,
      puppet_server               => $wr::common::puppet_server,
      puppet_master_ensure        => $wr::common::puppet_version,
      puppet_agent_ensure         => $wr::common::puppet_version,
      puppet_agent_service_enable => false,
      master                      => true,
      autosign                    => true,
      manifest                    => '$confdir/environments/$environment/manifests/site.pp',
      modulepath                  => '$confdir/environments/$environment/modules',
      puppet_passenger            => true,
      passenger_provider          => 'yum',
      passenger_package           => 'mod_passenger',
      passenger_ensure            => 'present',
      dashboard                   => true,
      dashboard_passenger         => true,
      dashboard_port              => '3000',
      dashboard_password          => 'dashb0ard',
      storeconfigs                => true,
      storeconfigs_dbadapter      => 'puppetdb',
      mysql_root_pw               => 'changemetoo', #needed for dashboard
      require                     => [ Yumrepo['puppetlabs-rh6'],
                                      Yumrepo['passenger-rh6']],
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
