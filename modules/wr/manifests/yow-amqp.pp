#
class wr::yow-amqp inherits wr::yow-common {

  #need to define these here due to template declared here
  #will move when I fix the activemq class
  $broker_name = 'yow-broker'
  $webconsole_real = true

  class { 'java': distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq':
    broker_name   => 'yow-broker',
    server_config => template('wr/yow-activemq.xml.erb')
  }
}
