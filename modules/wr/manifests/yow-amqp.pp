#
class wr::yow-amqp {

  class { 'yow::common': }
  -> class { 'wr::activemq': broker_name => 'yow-broker' }

}
