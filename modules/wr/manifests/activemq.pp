#
class wr::activemq( $broker_name ) {

  #need to define these here due to template declared here
  #will move when I fix the activemq class
  $webconsole_real = true
  $collectives = ['yow','ala','pek']
  $activemq_servers = { 'yow' => 'yow-lpg-amqp.wrs.com',
    'ala' => 'ala-lpd-puppet.wrs.com', 'pek' => 'pek-lpd-puppet.wrs.com' }

  realize( Redhat::Yum_repo['activemq'] )
  Yumrepo['activemq'] -> Class['activemq']

  class { 'java': distribution => 'java-1.7.0-openjdk' }
  -> class { '::activemq':
    broker_name    => $broker_name,
    version        => '5.7.0-1',
    server_config  => template('wr/activemq.xml.erb'),
    wrapper_config => template('wr/activemq-wrapper.conf.erb'),
    credentials    => template('wr/credentials.properties.erb')
  }
}
