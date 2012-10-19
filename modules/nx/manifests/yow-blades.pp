#
class nx::yow-blades {

  #create nx instances
  include nx::local_build
  nx::setup {
    [ '1', '2' ]:
  }
}
