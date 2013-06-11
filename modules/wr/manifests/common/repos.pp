#Setup all puppet managed machines to use internal mirrors
class wr::common::repos {
  $family=downcase($::osfamily)
  include $family

  anchor{'wr::common::repos::begin':}
  -> Class[$family]
  -> anchor{'wr::common::repos::end':}
}
