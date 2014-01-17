#
class git::grokmirror::monitor {

  include nagios::nsca::client
  @@nagios_service {
    "check_grokmirror_${::hostname}":
      use                 => 'passive-service',
      service_description => 'Grokmirror run check',
      host_name           => $::fqdn,
      servicegroups       => 'git-mirrors',
  }

  $nsca_server=hiera('nsca')

  cron {
    'nsca_grokmirror_check':
      command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S 'Grokmirror run check' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_grokmirror_log.sh -q",
      user    => 'nagios',
      minute  => '*/5';
  }

}
