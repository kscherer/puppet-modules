#
class wr::xenserver {

  include profile::monitored
  include collectd::disable
  include xen

  #set a strong generated password to encourage use of ssh authorized keys
  user {
    'root':
      password => '$6$lWv2aSVT1/Yd$yVsrcIydMlcq4fkB23EDq6zZSmnR0Ab0NskE39YVODV9fcIl/MLLa4EplwSR4x/EqDX6O/H8Q7CwpLHUdEZpn0';
  }

  #only run smart on the hostel builders
  if $::blockdevice_sda_model == 'PERC 6/i' {
    class {
      'smart':
        devices => {'/dev/sda'=>['megaraid,0', 'megaraid,1', 'megaraid,2', 'megaraid,3', 'megaraid,4', 'megaraid,5']};
    }
  }
}
