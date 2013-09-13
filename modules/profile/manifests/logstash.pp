#
class profile::logstash {
  include logstash

  include logstash::output::elasticsearch
}
