#
class wr::yow_lpd_provision {
  include ::profile::nis
  include ::wr::foreman_common
  include ::ssmtp

  #setup yow-lpd-provision as yow internal docker registry
  include profile::docker::registry

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

  dhcp::host {
    'yow-lpgbld-apc3': mac => '00:c0:b7:60:11:e6', ip => '128.224.194.252';
  }
}
