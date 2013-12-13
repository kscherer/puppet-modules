#
class role::provisioner {
  include profile::nis

  cron {
    'delete_foreman_reports':
      ensure  => present,
      user    => 'root',
      hour    => '0',
      minute  => '0',
      command => '/usr/sbin/foreman-rake reports:expire days=1 status=0; /usr/sbin/foreman-rake reports:expire days=7';
  }

  #test dhcp module in yow only for now
  if $::hostname == 'yow-lpd-provision' {
    include dhcp

    concat::fragment { 'dhcp-conf-omapi':
      target  => "${dhcp::dhcp_dir}/dhcpd.conf",
      content => 'omapi-port 7911;',
      order   => 80,
    }

    dhcp::pool{ 'host-test-lab.wrs.com':
      network => '128.224.194.0',
      mask    => '255.255.255.0',
      range   => '128.224.194.95 128.224.194.99',
      gateway => '128.224.194.1',
    }
  }
}
