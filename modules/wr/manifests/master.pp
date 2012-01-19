# Define the default puppet master setup for WindRiver

class wr::master {

  Class['redhat']
  -> Class['java']
  -> Class['activemq']
  -> Class['mysql']
  -> Class['mysql::ruby']
  -> Class['wr::mcollective']
  -> Class['wr::master']

  class {
    puppet:
      agent                       => true,
      puppet_agent_ensure         => 'present',
      puppet_agent_service_enable => false,
      puppet_server => $::hostname ? {
        /^ala.*$/                 => 'ala-lpd-puppet.wrs.com',
        /^pek.*$/                 => 'pek-lpd-puppet.wrs.com',
        /^yow.*$/                 => 'yow-lpd-puppet.ottawa.wrs.com',
      },
      master                      => true,
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
      thinstoreconfigs            => true,
      storeconfigs_dbuser         => 'puppet',
      storeconfigs_dbpassword     => 'windriver-puppet',
      storeconfigs_dbsocket       => '/var/lib/mysql/mysql.sock',
      mysql_root_pw               => 'r00t',
      activerecord_provider       => 'yum',
      activerecord_package        => 'rubygem-activerecord',
      activerecord_ensure         => '3.0.11-1',
      require                     => [ Yumrepo['puppetlabs-rh6'],
                                       Yumrepo['passenger-rh6']],
  }

  cron {
    'report_clean':
      command => '/usr/bin/find /var/lib/puppet/reports -ctime +7 -name \'*.yaml\' -exec rm {} \; &> /dev/null',
      user => 'puppet',
      minute => '0',
      hour => '2';
    'clean_dashboard':
      command => 'cd /usr/share/puppet-dashboard; rake RAILS_ENV=production reports:prune upto=1 unit=wk &> /dev/null',
      minute => '0',
      hour => '2';
    'optimize_dashboard':
      command => 'cd /usr/share/puppet-dashboard; rake RAILS_ENV=production db:raw:optimize &> /dev/null',
      minute => '0',
      hour => '3',
      weekday => '0';
  }
}
