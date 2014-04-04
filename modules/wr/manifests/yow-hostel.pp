#
class wr::yow-hostel {

  include profile::nxbuilder

  user {
    'root':
      password => '$6$vEbdCo3ZF/z2cq9$MawClitGcpDau8b26qI.r/VRFCmJM.MrA41vRimQr69.XPgOac7A.Vc7oNoNb4wELuUtWzcDtWlmsNKbnxXSX0';
  }

  motd::register{
    'yow-hostel':
      content => 'This machine is reserved for the Ottawa Host Test Lab.';
  }
}
