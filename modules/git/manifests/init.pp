#
class git {

  include git::package

  anchor{'git::begin': }
  -> Class['git::package']
  -> anchor{'git::end': }
}
