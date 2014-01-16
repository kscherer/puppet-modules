#
class profile::git::mirror inherits profile::git::base {
  include git::wr_bin_repo
  include git::grokmirror::mirror
  include git::grokmirror::monitor
}
