#
class wr::fileserver {
  include ::profile::nis
  include ::rsync
  include ::apache
  include ::collectd
  include ::role::git::mirror

  ensure_packages(['libc6-dev'])
  include ::zfs
  Package['libc6-dev'] -> Class['zfs']

  # Machine has 2 SSD and 12 HDD. SSD is setup as RAID1 and
  # each HDD is setup as single RAID0 because controller doesn't
  # support JBOD.
  #
  # Initial provision setup 10GB for OS and 4GB for swap
  # Remaining space partitioned for ZFS caches
  # delete home partition: parted -s /dev/sda rm 4
  # create zil (journal): parted -s /dev/sda -- mkpart zil 15GB 19GB
  # create l2arc ssd cache: parted -s /dev/sda -- mkpart l2arc 19GB -1
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
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      require  => Package['nfs-kernel-server'];
    'pool/mentor':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      require  => Package['nfs-kernel-server'];
    'pool/git':
      ensure     => present,
      atime      => 'off',
      mountpoint => '/git',
      setuid     => 'off',
      devices    => 'off';
    'pool/stored_builds':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '2T',
      require  => Package['nfs-kernel-server'];
    'pool/prj-wrlinux':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      require  => Package['nfs-kernel-server'];
    'pool/sustaining':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      require  => Package['nfs-kernel-server'];
    'pool/other_builds':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '2T',
      require  => Package['nfs-kernel-server'];
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

  #zfs nfs support requires a default mount option in exports
  file {
    '/etc/exports':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => '/mnt localhost(ro)';
  }

  package {
    'nfs-kernel-server':
      ensure  => installed,
      require => File['/etc/exports'];
  }

  service {
    'nfs-kernel-server':
      ensure    => running,
      require   => [ Package['nfs-kernel-server'], File['/etc/exports']];
  }

  package {
    'fuseiso':
      ensure  => installed;
  }

  file {
    '/home/svc-mirror':
      ensure => directory;
    '/etc/fuse.conf':
      ensure  => present,
      require => Package['fuseiso'],
      content => "user_allow_other\n";
    '/git':
      ensure  => directory,
      owner   => 'git',
      group   => 'users',
      require => Zfs['pool/git'];
  }

  File['/git'] -> Class['::role::git::mirror']

  case $::location {
    'yow': { $svc_mirror_home = 'yow-nas2:/vol/vol1/UNIX-Home/svc-mirror' }
    default: { $svc_mirror_home = 'ala-nas2:/vol/vol0/UNIX-Home/svc-mirror' }
  }

  mount {
    '/home/svc-mirror':
      ensure  => mounted,
      device  => $svc_mirror_home,
      atboot  => true,
      fstype  => 'nfs',
      options => 'rw',
      require => File['/home/svc-mirror'];
  }

  file {
    '/etc/ubumirror.conf':
      ensure => link,
      target => "/home/svc-mirror/mirror-configs/ubumirror.conf.${::hostname}";
  }

  cron {
    'dell_linux_repo':
      ensure      => present,
      command     => '/usr/bin/rsync -avHz --delete --delete-delay --exclude-from=/home/svc-mirror/mirror-configs/dell-excludes linux.dell.com::repo /pool/mirror/dell > /pool/mirror/log/dell_repo.log',
      environment => ['HOME=/home/svc-mirror',
                      'PATH=/usr/bin:/bin/:/sbin/:/usr/sbin',
                      'MAILTO=konrad.scherer@windriver.com'],
      user        => 'svc-mirror',
      hour        => '5',
      minute      => '0';
    'mirror-rsync':
      ensure  => present,
      command => '/home/svc-mirror/mirror-rsync/mirror-fedora > /pool/mirror/log/mirror-rsync.log',
      user    => 'svc-mirror',
      hour    => '23',
      minute  => '0';
    'ubuntu_archives':
      ensure  => present,
      command => '/home/svc-mirror/mirror-configs/ubuarchive',
      user    => 'svc-mirror',
      hour    => '2',
      minute  => '0';
    'ubuntu_releases':
      ensure  => present,
      command => '/home/svc-mirror/mirror-configs/uburelease',
      user    => 'svc-mirror',
      hour    => '1',
      minute  => '0';
  }

  #dell repo needs to be able to exec cgi scripts
  apache::vhost {
    "mirror-${::hostname}":
      port             => '80',
      docroot          => '/var/www/',
      directories      =>
      [{
        path           => '/var/www/',
        options        => ['Indexes', 'FollowSymLinks', 'MultiViews', 'ExecCGI'],
        allow_override => ['None'],
        order          => ['Allow','Deny'],
        allow          => 'from all',
        addhandlers    => [{ handler => 'cgi-script', extensions => ['.cgi']}],
       },
       {
        path           => '/usr/lib/cgit',
        options        => ['FollowSymLinks', 'ExecCGI'],
      }],
      scriptaliases => [{
                        alias => '/cgit/',
                        path  => '/usr/lib/cgit/cgit.cgi/',
                        }],
      aliases => [{
                  alias => '/cgit-css',
                  path  => '/usr/share/cgit',
                  }],
      redirectmatch_status => ['^/cgit$'],
      redirectmatch_regexp => ['/cgit'],
  }

  include rsync::server
  rsync::server::module{
    'centos':
      path => '/pool/mirror/centos',;
    'epel':
      path => '/pool/mirror/epel';
    'puppetlabs':
      path => '/pool/mirror/puppetlabs';
    'ubuntu':
      path => '/pool/mirror/ubuntu.com/ubuntu';
    'ubuntu-releases':
      path => '/pool/mirror/ubuntu.com/ubuntu-releases';
  }

  # cgit installation and config
  apt::ppa { 'ppa:kmscherer/cgit': }
  package {
    ['cgit','highlight', 'python-pygments', 'markdown']:
      ensure => installed;
  }
  Apt::Ppa['ppa:kmscherer/cgit'] -> Package['cgit']

  file {
    '/var/cache/cgit':
      ensure => directory,
      mode   => '0755',
      owner  => 'www-data',
      group  => 'www-data';
  }

  # needed to retrieve artifacts from Mentor Graphics
  package {
    ['subversion', 'mercurial']:
      ensure => installed;
  }

  # setup x2go server to provide remote graphical access in all DCs
  class {
    'x2go::server':
      ensure => true;
  }
}
