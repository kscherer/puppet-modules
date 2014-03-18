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
  include nagios::hostgroup
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
  }

  include apache
  include apache::mod::php

  apache::vhost {
    'nagios':
      port        => '80',
      alias       => [{'/nagios' => '/usr/share/nagios/html'}],
      scriptalias => [{'/nagios/cgi-bin/' => '/usr/lib64/nagios/cgi-bin'}],
      directories => [{
                      path           => '/usr/lib64/nagios/cgi-bin/',
                      options        => 'ExecCGI',
                      allow_override => ['None'],
                      order          => ['Allow','Deny'],
                      allow          => 'from all',
                      auth_name      => 'Nagios Access',
                      auth_type      => 'Basic',
                      auth_user_file => '/etc/nagios/passwd',
                      auth_require   => 'valid-user',
                      }, {
                      path           => '/usr/share/nagios/html',
                      options        => 'None',
                      allow_override => ['None'],
                      order          => ['Allow','Deny'],
                      allow          => 'from all',
                      auth_name      => 'Nagios Access',
                      auth_type      => 'Basic',
                      auth_user_file => '/etc/nagios/passwd',
                      auth_require   => 'valid-user',
                      }],
  }
}
