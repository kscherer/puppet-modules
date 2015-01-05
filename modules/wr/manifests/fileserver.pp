#
class wr::fileserver {
  include ::profile::nis
  include ::rsync

  ensure_packages(['libc6-dev'])
  include ::zfs
  Package['libc6-dev'] -> Class['zfs']
}
