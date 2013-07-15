#
class role {
  include profile::base
}

#
class role::git::master inherits role {
}

#
class role::git::mirror inherits role {
  include profile::git::mirror
}


