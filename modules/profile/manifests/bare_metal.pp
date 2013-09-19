#
class profile::bare_metal {
  include dell
  include dell::openmanage
  include dell::warranty

  @@nagios_service {
    "check_openmanage_${::hostname}":
      use                 => 'passive-service',
      service_description => 'Passive OpenManage',
      host_name           => $::fqdn,
      servicegroups       => 'dell-servers',
  }

  $nsca_server=hiera('nsca')
  $min=fqdn_rand(60)

  cron {
    'nsca_openmanage_check':
      command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S 'Passive OpenManage' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_openmanage.sh -q",
      user    => 'nagios',
      minute  => $min;
  }

  if 'blade' in $::hostname {
    
  }

}
