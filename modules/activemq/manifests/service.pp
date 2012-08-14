# Class: activemq::service
#
#   Manage the ActiveMQ Service
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::service(
  $ensure
) {

  # Arrays cannot take anonymous arrays in Puppet 2.6.8
  $v_ensure = [ '^running$', '^stopped$' ]
  validate_re($ensure, $v_ensure)

  $ensure_real = $ensure

  service { 'activemq':
    ensure     => $ensure_real,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['activemq::packages'],
  }

  #restart activemq once a week after sleeping between 0 and 10 minutes
  cron {
    'weekly_activemq_restart':
      ensure  => present,
      command => '/bin/sleep `/usr/bin/expr $RANDOM % 600`; /bin/service activemq restart',
      user    => 'root',
      minute  => '0',
      hour    => '0',
      weekday => '0';
  }
}
