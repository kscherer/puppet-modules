#
class wr::yow-buildbot-slave inherits wr::mcollective {

  include profile::nis
  include yocto
  include buildbot::slave

  user {
    'root':
      password =>
        '$6$vEbdCo3ZF/z2cq9$MawClitGcpDau8b26qI.r/VRFCmJM.MrA41vRimQr69.XPgOac7A.Vc7oNoNb4wELuUtWzcDtWlmsNKbnxXSX0';
  }

  motd::register{
    'yow-buildbot':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }

}
