class yocto {
  case $::osfamily {
    RedHat: { include yocto::redhat }
    Debian: { include yocto::debian }
    Suse:   { include yocto::suse }
    default:{ fail("Unsupported OS $::osfamily") }
  }
}
