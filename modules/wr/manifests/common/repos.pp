#Setup all puppet managed machines to use internal mirrors
class wr::common::repos {
  case $::osfamily {
    Debian: { include debian }
    RedHat: { include redhat }
    Suse:   { include suse }
    default:{ fail("Unsupported OS: ${::osfamily}")}
  }
}
