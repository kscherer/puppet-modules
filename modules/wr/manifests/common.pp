#
class wr::common {

  #Create standard base motd
  include motd
  include ntp
  include wr::common::ssh_root_keys
  include wr::common::etc_host_setup
  include wr::common::bash_configs
  include wr::workaround::xen
}
