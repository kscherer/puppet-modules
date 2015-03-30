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
      range   => '128.224.137.96 128.224.137.100',
      gateway => '128.224.137.1';
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
    ['tftpd-hpa', 'syslinux']:
      ensure => installed;
  }

  service {
    'tftpd-hpa':
      ensure => running;
  }

  file {
    '/var/lib/tftpboot':
      ensure => directory,
      owner  => 'foreman-proxy',
      group  => 'foreman-proxy',
      mode   => '0755';
    '/var/lib/tftpboot/efi':
      ensure => directory,
      owner  => 'foreman-proxy',
      group  => 'foreman-proxy',
      mode   => '0755';
    '/var/lib/tftpboot/efi/syslinux.efi':
      ensure => present,
      owner  => 'foreman-proxy',
      group  => 'foreman-proxy',
      source => 'puppet:///modules/wr/syslinux.efi';
    '/var/lib/tftpboot/efi/ldlinux.e64':
      ensure => present,
      owner  => 'foreman-proxy',
      group  => 'foreman-proxy',
      source => 'puppet:///modules/wr/ldlinux.e64';
  }
}
