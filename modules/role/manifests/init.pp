#
class role {
  include profile::base
}

#
class role::git::master inherits role {
  include profile::git::master
}

#
class role::git::mirror inherits role {
  include profile::git::master
}


