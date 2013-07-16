#
class role {
  include profile::base
}

#
class role::git::master inherits role {
  #only use base for now. Hopefully will be extended to include more resources
}

#
class role::git::mirror inherits role {
  include profile::git::mirror
}


