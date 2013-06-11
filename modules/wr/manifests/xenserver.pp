#
class wr::xenserver(
  $client = false
  ) {

  class { 'debian': }
  -> class { 'wr::common': }
  -> class { 'wr::mcollective': client => $client }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'collectd::disable': }
  -> class { 'nagios::target': }
  -> class { 'xen': }

  #set a strong generated password to encourage use of ssh authorized keys
  user {
    'root':
      password => '$6$lWv2aSVT1/Yd$yVsrcIydMlcq4fkB23EDq6zZSmnR0Ab0NskE39YVODV9fcIl/MLLa4EplwSR4x/EqDX6O/H8Q7CwpLHUdEZpn0';
  }
}
