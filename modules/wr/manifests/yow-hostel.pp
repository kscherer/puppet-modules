#
class wr::yow-hostel {

  case $::operatingsystem {
    Debian,Ubuntu: { $base_class='debian' }
    CentOS,RedHat,Fedora: { $base_class='redhat' }
    OpenSuSE,SLED: { $base_class='suse'}
    default: { fail("Unsupported OS: ${::operatingsystem}")}
  }

  class { $base_class: }
  -> class { 'wr::common': }
  -> class { 'wr::mcollective': }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'yocto': }
  -> class { 'nx': }
  -> class { 'nagios::target': }
  -> class { 'sudo': }

  user {
    'root':
      password =>
        '$6$vEbdCo3ZF/z2cq9$MawClitGcpDau8b26qI.r/VRFCmJM.MrA41vRimQr69.XPgOac7A.Vc7oNoNb4wELuUtWzcDtWlmsNKbnxXSX0';
  }

  motd::register{
    'yow-hostel':
      content => 'This machine is reserved for the Ottawa Host Test Lab.';
  }
}
