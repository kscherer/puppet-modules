#
class wr::activemq( $broker_name ) {

  #need to define these here due to template declared here
  #will move when I fix the activemq class
  $webconsole_real = true
  $collectives = ['yow','ala','pek']
  $activemq_servers = { 'yow' => 'yow-lpd-puppet2.wrs.com',
    'ala' => 'ala-lpd-puppet.wrs.com', 'pek' => 'pek-lpd-puppet.wrs.com' }

  realize( RedHat::Yum_repo['activemq'] )

  include java
  class { '::activemq':
    broker_name   => $broker_name,
    server_config => template('wr/activemq.xml.erb'),
    require       => Yumrepo['activemq'];
  }

  Class['java'] -> Class['::activemq']
}
