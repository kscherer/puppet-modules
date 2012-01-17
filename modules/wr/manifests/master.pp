# Define the default puppet master setup for WindRiver

class wr::master {

  Class['redhat']
  -> Class['java']
  -> Class['activemq']
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
        /^yow.*$/                 => 'yow-lpgbld-master.ottawa.wrs.com',
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
}
