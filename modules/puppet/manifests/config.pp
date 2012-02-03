#
class puppet::config inherits puppet::params {

  include concat::setup

  #This resource will be overridden in master and agent subclass
  @concat {
    $puppet::params::puppet_conf:
      mode    => '0644',
  }
}
