# Install x2go server
class x2go {
  include x2go::package
  anchor{'x2go::begin': }
  -> Class['x2go::package']
  -> anchor{'x2go::end': }
}
