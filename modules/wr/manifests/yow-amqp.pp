#
class wr::yow-amqp {

  class { 'wr::yow-common': }
  -> class { 'wr::activemq': broker_name => 'yow-broker' }

}
