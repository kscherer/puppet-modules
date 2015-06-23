#
class wr::ala_lpd_provision {
  include ::profile::nis
  include ::wr::foreman_common
  include ::postfix
  include ::zookeeper
}
