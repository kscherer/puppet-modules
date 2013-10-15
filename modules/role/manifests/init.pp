#
class role {
  include profile::base
}

#
class role::provisioner {
  include profile::nis
}
