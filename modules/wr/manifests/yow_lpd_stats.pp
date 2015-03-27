#
class wr::yow_lpd_stats {
  include profile::nis
  include ::logstash
  include ::debian::foreman

  include ::dhcp

  # need omapi support for foreman proxy
  concat::fragment {
    'dhcp-conf-omapi':
      target  => "${dhcp::dhcp_dir}/dhcpd.conf",
      content => 'omapi-port 7911;',
      order   => 80,
  }

  dhcp::pool{
    'yow-blades':
      network => '128.224.137.0',
      mask    => '255.255.255.0',
      range   => '128.224.137.11 128.224.137.100',
      gateway => '128.224.137.1';
  }

  exec {
    'dhcpd_on_em1':
      command => '/bin/sed -i \'s/INTERFACES=\"eth0\"/INTERFACES=\"em1\"/g\' /etc/default/isc-dhcp-server',
      onlyif  => '/bin/grep INTERFACES=\"eth0\" /etc/default/isc-dhcp-server',
      notify  => Service['isc-dhcp-server'];
  }

  package {
    'foreman-proxy':
      ensure  => installed,
      require => Apt::Source['foreman'];
  }

  user {
    'foreman-proxy':
      ensure => present,
      groups => 'puppet';
  }

  group {
    'foreman-proxy':
      ensure => present;
  }

  service {
    'foreman-proxy':
      ensure    => running,
      hasstatus => true,
      enable    => true,
      require   => Package['foreman-proxy'];
  }

  package {
    'tftpd-hpa':
      ensure => installed;
  }

  service {
    'tftpd-hpa':
      ensure => running;
  }
}
