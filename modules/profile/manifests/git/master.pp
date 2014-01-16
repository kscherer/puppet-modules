#
class profile::git::master inherits profile::git::base {
  include git::grokmirror::master
}
