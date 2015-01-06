#
class wr::fileserver {
  include ::profile::nis
  include ::rsync
  include ::apache

  ensure_packages(['libc6-dev'])
  include ::zfs
  Package['libc6-dev'] -> Class['zfs']

  # Machine has 2 SSD and 12 HDD. SSD is setup as RAID1 and
  # each HDD is setup as single RAID0 because controller doesn't
  # support JBOD.
  #
  # Initial provision setup 10GB for OS and 4GB for swap
  # Remaining space partitioned for ZFS caches
  #
  # Setup hard drives with initial label
  # for arg in {b..m}; do parted -s /dev/sd$arg mklabel gpt; done
  #
  # initial zfs setup
  # specify ashift because disks are 4K disks
  # specify disks by pci path so when disks are replaced the name stays the same
  # zpool create -o ashift=12 pool raidz2 /dev/disk/by-path/pci-0000\:03\:00.0-scsi-0\:2\:[1-9]*:0
  #
  # Add ZFS intent log (equivalent to ext4 journal) and L2ARC cache on SSD
  # zpool add pool log /dev/sda4 cache /dev/sda5

  zfs {
    'pool':
      ensure      => present,
      atime       => 'off';
    'pool/mirror':
      ensure   => present,
      atime    => 'off',
      setuid   => 'off',
      devices  => 'off';
  }

  # scrub zfs filesystem weekly
  cron {
    'zfs_scrub':
      ensure  => present,
      command => '/sbin/zpool scrub pool',
      user    => 'root',
      weekday => '6', #Saturday
      hour    => '22',
      minute  => '0';
  }

  motd::register{
    'ala-lpggp':
      content => "Welcome to Linux Group File Server.
      NO BUILDS or VNC sessions!";
  }
}
