#
class role::git::master inherits role {
  include git
  include nis

  include nrpe
  include nagios::target
  include profile::bare_metal

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['nagios::target']
  Class['wr::common::repos'] -> Class['git']
  Class['wr::common::repos'] -> Class['nis']
  Class['wr::common::repos'] -> Class['profile::bare_metal']

  #add logrotate entries for apache to keep logs from overflowing /var
  include logrotate::base
  logrotate::rule {
    'httpd':
      ensure        => 'present',
      path          => '/var/log/httpd/*log',
      rotate        => 7,
      rotate_every  => 'day',
      compress      => true,
      missingok     => true,
      ifempty       => false,
      dateext       => true,
      sharedscripts => true,
      postrotate    => '/sbin/service httpd reload > /dev/null 2>/dev/null || true',
  }
}
