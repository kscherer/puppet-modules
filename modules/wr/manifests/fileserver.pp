#
class wr::fileserver {
  include ::profile::nis
  include ::rsync
  include ::zfs
}
