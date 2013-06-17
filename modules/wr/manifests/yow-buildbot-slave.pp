#
class wr::yow-buildbot-slave inherits wr::mcollective {

  case $::operatingsystem {
    Debian,Ubuntu: { $base_class='debian' }
    CentOS,RedHat,Fedora: { $base_class='redhat' }
    OpenSuSE,SLED: { $base_class='suse'}
    default: { fail("Unsupported OS: $::operatingsystem")}
  }

  class { $base_class: }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'yocto': }
  -> class { 'buildbot::slave': }
  -> class { 'nagios::target': }

  user {
    'root':
      password =>
        '$6$vEbdCo3ZF/z2cq9$MawClitGcpDau8b26qI.r/VRFCmJM.MrA41vRimQr69.XPgOac7A.Vc7oNoNb4wELuUtWzcDtWlmsNKbnxXSX0';
  }
  include motd
  motd::register{
    'yow-buildbot':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }

}
