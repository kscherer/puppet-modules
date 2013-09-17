#
class nagios(
  $nagios_dir  = $nagios::params::nagios_dir,
  ) inherits nagios::params {

  package {
    ['nagios', 'nagios-plugins-all', 'php']:
      ensure => 'latest';
  }

  service {
    'nagios':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => Package['nagios'],
      require    => [ File['nagios_conf'], Package['nagios']],
  }

  File {
    require => Package['nagios'],
    owner   => 'root',
    group   => 'nagios',
    mode    => '0664',
  }

  include nagios::command
  include nagios::contact
  include nagios::host
  include nagios::service
  include nagios::servicegroup
  include nagios::timeperiod

  file {
    "${nagios_dir}/objects":
      ensure  => directory,
      mode    => '0755';
    'nagios_conf':
      path    => "${nagios_dir}/nagios.cfg",
      source  => 'puppet:///modules/nagios/nagios.cfg',
      notify  => Service['nagios'];
    'cgi_conf':
      path    => "${nagios_dir}/cgi.cfg",
      source  => 'puppet:///modules/nagios/cgi.cfg',
      notify  => Service['httpd'];
    'nagios_htpasswd':
      path    => "${nagios_dir}/passwd",
      source  => 'puppet:///modules/nagios/passwd',
      notify  => Service['httpd'],
      mode    => '0640',
      owner   => root,
      group   => apache;
    'nagios_http_conf':
      ensure  => 'present',
      path    => '/etc/httpd/conf.d/nagios.conf',
      mode    => '0644',
      owner   => root,
      group   => root;
    'nagios_php_conf':
      ensure  => 'present',
      path    => '/etc/httpd/conf.d/php.conf',
      mode    => '0644',
      owner   => root,
      group   => root;
  }
}
