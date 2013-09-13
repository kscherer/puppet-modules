#
class profile::logstash {
  include ::logstash

  logstash::output::elasticsearch {
    'elasticsearch':
      embedded => true
  }
}
