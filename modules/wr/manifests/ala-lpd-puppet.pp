#
class wr::ala-lpd-puppet {
  class {'wr::ala_dns': }
  -> class { 'redhat': }
  -> class { 'ntp': servers => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'wr::activemq': broker_name => 'ala-broker' }
  -> class { 'wr::master': }
  -> class { 'git::stomp_listener': }
  -> class { 'wr::puppetcommander': }

  Class['redhat'] -> class { 'nrpe': }
  class { 'nagios': }
  class { 'nagios::target': }
}
