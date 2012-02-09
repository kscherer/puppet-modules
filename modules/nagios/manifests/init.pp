#
class nagios(
  $nagios_dir  = $nagios::params::nagios_dir,
  $nagios_conf = $nagios::params::nagios_conf
  ) inherits nagios::params {
  package {
    ['nagios', 'nagios-plugins-all', 'php']:
      ensure => 'latest';
  }

  service {
    'nagios':
      ensure     => 'running',
      hasstatus  => true,
      hasrestart => true,
      require    => Package['nagios'],
  }

  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host <<||>> {
    target  => "${nagios_conf}/nagios_host.cfg",
    notify  => Service['nagios'],
    require => File[$nagios_conf],
  }

  Nagios_service <<||>> {
    target  => "${nagios_conf}/nagios_service.cfg",
    notify  => Service['nagios'],
    require => File[$nagios_conf],
  }

  Nagios_hostextinfo <<||>> {
    target  => "${nagios_conf}/nagios_hostextinfo.cfg",
    notify  => Service['nagios'],
    require => File[$nagios_conf],
  }

  file {
    #make sure all files in /etc/nagios/conf.d have world read permissions
    $nagios_conf:
      ensure  => directory,
      recurse => true,
      purge   => true,
      mode    => '0755';
    "${nagios_dir}/objects":
      ensure => directory,
      mode   => '0755';
    "${nagios_dir}/nagios.cfg":
      source => 'puppet:///nagios/nagios.cfg',
      notify => Service['nagios'],
      mode   => '0644';
    "${nagios_dir}/cgi.cfg":
      source => 'puppet:///nagios/cgi.cfg',
      notify => Service['httpd'],
      mode   => '0644';
    'nagios_htpasswd':
      path   => "${nagios_dir}/passwd",
      notify => Service['httpd'],
      source => 'puppet:///nagios/passwd',
      mode   => '0640', owner => root, group => apache;
    [ "${nagios_conf}/nagios_hostextinfo.cfg",
      "${nagios_conf}/nagios_host.cfg",
      "${nagios_conf}/nagios_service.cfg"]:
        notify  => Service['nagios'],
        mode    => '0644';
  }
}
