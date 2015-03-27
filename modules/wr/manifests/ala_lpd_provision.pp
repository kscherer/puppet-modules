#
class wr::ala_lpd_provision {
  include ::profile::nis
  include ::wr::foreman_common
  include ::ssmtp
  include ::zookeeper
}
