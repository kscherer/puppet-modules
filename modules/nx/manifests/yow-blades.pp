#
class nx::yow-blades {

  #create nx instances
  nx::setup {
    [ '1', '2' ]:
  }

  case $::hostname {
    yow-blade1: { include nx::local_build }
    /^yow-blade[2-8]$/: { include nx::local_build }
    yow-blade9: { include nx::md3000_iscsi_setup }
    /^yow-blade1[0-6]$/: { include nx::md3000_iscsi_setup }
    default: { fail("Do not know how to configure nx for $::hostname")}
  }
}
