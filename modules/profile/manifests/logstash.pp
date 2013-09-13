#
class profile::logstash {
  include ::logstash

  logstash::input::file {
    'syslog':
      type => 'syslog',
      path => [ '/var/log/messages', '/var/log/syslog' ];
  }

  logstash::output::elasticsearch {
    'elasticsearch':
      embedded => true
  }
}
