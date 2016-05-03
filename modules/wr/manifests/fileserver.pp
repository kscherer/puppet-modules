#
class wr::fileserver {
  include ::profile::nis
  include ::rsync
  include ::apache
  include ::role::git::mirror
  include ::postfix

  ensure_packages( ['libc6-dev', 'vim-nox', 'screen', 'curl', 'wget', 'tmux',
                    'diffstat', 'reprepro', 'unzip'])
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
      sharenfs   => 'on',
      mountpoint => '/git',
      setuid     => 'off',
      devices    => 'off';
    'pool/users':
      ensure     => present,
      atime      => 'off',
      mountpoint => '/git/users',
      setuid     => 'off',
      quota      => '500G',
      devices    => 'off';
    'pool/stored_builds':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '10T',
      require  => Package['nfs-kernel-server'];
    'pool/prj-wrlinux':
      ensure   => absent,
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
      quota    => '3T',
      require  => Package['nfs-kernel-server'];
    'pool/other_builds':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '2T',
      require  => Package['nfs-kernel-server'];
    'pool/ovp':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '2T',
      require  => Package['nfs-kernel-server'];
    'pool/cache':
      ensure   => present,
      atime    => 'off',
      setuid   => 'off',
      devices  => 'off',
      quota    => '100G';
    'pool/wrlinux_installs':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '2T',
      require  => Package['nfs-kernel-server'];
    'pool/export_sources':
      ensure   => present,
      atime    => 'off',
      sharenfs => 'on',
      setuid   => 'off',
      devices  => 'off',
      quota    => '50G',
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
  include nfs::server

  file {
    '/git/users':
      ensure  => directory,
      owner   => 'git',
      group   => 'users',
      mode    => '0775',
      require => Zfs['pool/users'];
    '/pool/mirror':
      ensure  => directory,
      owner   => 'svc-mirror',
      group   => 'users',
      mode    => '0755',
      require => Zfs['pool/mirror'];
    '/pool/ovp':
      ensure  => directory,
      owner   => 'root',
      group   => 'users',
      mode    => '0775',
      require => Zfs['pool/ovp'];
    '/pool/wrlinux_installs':
      ensure => directory,
      owner  => wrlbuild,
      group  => users,
      mode   => '0775',
      require => Zfs['pool/wrlinux_installs'];
  }

  package {
    ['fuseiso', 'createrepo', 'apt-mirror']:
      ensure  => installed;
  }

  group {
    'fuse':
      ensure => present,
      members => 'svc-mirror',
      require => Package['fuseiso'];
  }

  file {
    '/home/svc-mirror':
      ensure => directory;
    '/etc/fuse.conf':
      ensure  => present,
      require => Package['fuseiso'],
      owner   => 'root',
      group   => 'fuse',
      mode    => '0640',
      content => "user_allow_other\n";
    '/git':
      ensure  => directory,
      owner   => 'git',
      group   => 'users',
      require => Zfs['pool/git'];
    '/git/git':
      ensure  => link,
      target  => '.',
      owner   => 'git',
      group   => 'users',
      require => File['/git'];
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
    '/etc/mirrormanager-client/':
      ensure => directory;
    '/etc/mirrormanager-client/report_mirror.conf':
      ensure => link,
      target => "/home/svc-mirror/mirror-rsync/report_mirror.conf.${::hostname}";
    '/pool/mirror/apt':
      ensure => directory,
      owner  => 'svc-mirror',
      group  => 'mirror';
    '/pool/mirror/apt/mirror.list':
      ensure => present,
      owner  => 'svc-mirror',
      group  => 'mirror',
      source => 'puppet:///modules/wr/mirror.list';
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
    'make_iso_links':
      ensure  => present,
      command => '/home/svc-mirror/mirror-configs/mk_iso_links.sh',
      user    => 'svc-mirror',
      hour    => '6',
      minute  => '0';
    'apt-mirror-sync':
      ensure  => present,
      command => '/usr/bin/apt-mirror /pool/mirror/apt/mirror.list > /pool/mirror/apt/apt-mirror.log',
      user    => 'svc-mirror',
      hour    => '3',
      minute  => '0',
      require => Package['apt-mirror'];
  }

  include ::apache::mod::proxy
  include ::apache::mod::proxy_http

  #dell repo needs to be able to exec cgi scripts
  apache::vhost {
    "mirror-${::hostname}":
      port        => '80',
      docroot     => '/var/www/',
      directories => [{
        path           => '/var/www/',
        options        => ['Indexes', 'FollowSymLinks', 'MultiViews', 'ExecCGI'],
        allow_override => ['None'],
        order          => ['Allow','Deny'],
        allow          => 'from all',
        addhandlers    => [{ handler => 'cgi-script', extensions => ['.cgi'] }]
        },
        { path => '/usr/lib/cgit', options => ['FollowSymLinks', 'ExecCGI'] }
      ],
      scriptaliases => [
        { alias => '/cgit/', path  => '/usr/lib/cgit/cgit.cgi/'}
      ],
      aliases => [
        { alias => '/cgit-data', path  => '/usr/share/cgit'}
      ],
      redirectmatch_status => ['301','301'],
      redirectmatch_regexp => ['^/cgit$','^/consul$'],
      redirectmatch_dest   => ['/cgit/','/consul/'],
      proxy_pass => [
        { 'path' => '/consul', 'url' => 'http://127.0.0.1:8500/ui' },
        { 'path' => '/v1', 'url' => 'http://127.0.0.1:8500/v1' },
      ],
  }

  include rsync::server
  rsync::server::module{
    'centos':
      outgoing_chmod => 'D755,F644',
      path           => '/pool/mirror/centos';
    'epel':
      outgoing_chmod => 'D755,F644',
      path           => '/pool/mirror/epel';
    'puppetlabs':
      outgoing_chmod => 'D755,F644',
      path           => '/pool/mirror/puppetlabs';
    'ubuntu':
      outgoing_chmod => 'D755,F644',
      path           => '/pool/mirror/ubuntu.com/ubuntu';
    'ubuntu-releases':
      outgoing_chmod => 'D755,F644',
      path           => '/pool/mirror/ubuntu.com/ubuntu-releases';
  }

  if $::location == 'yow' {
    cron {
      'debian':
        ensure  => present,
        command => '/home/svc-mirror/mirror-configs/ftpsync',
        user    => 'svc-mirror',
        hour    => '22',
        minute  => '0';
    }

    rsync::server::module {
      'lava':
        path           => '/pool/ovp/lava/common',
        list           => 'yes',
        incoming_chmod => 'D775,F664',
        outgoing_chmod => 'D755,F644',
        read_only      => 'no',
        uid            => '1000',
        gid            => '100';
    }

    file {
      ['/pool/ovp/lava', '/pool/ovp/lava/common']:
        ensure  => directory,
        owner   => 'root',
        group   => 'users',
        mode    => '0777',
        require => Zfs['pool/ovp'];
    }
  }

  include git::cgit

  file {
    '/var/cache/cgit':
      ensure => absent,
  }

  # needed to retrieve artifacts from Mentor Graphics
  package {
    ['subversion', 'mercurial']:
      ensure => installed;
  }

  include x2go

  zfs {
    'pool/registry':
      ensure     => present,
      atime      => 'off',
      mountpoint => '/opt/registry',
      setuid     => 'off',
      devices    => 'off';
  }
  include ::profile::docker::registry
  Zfs['pool/registry'] -> Class['profile::docker::registry']

  if $::location != 'otp' {
    # Running zookeeper on vms is problematic due to extra network latency
    # The fileservers will be fairly idle and should make good zookeeper nodes
    include zookeeper
  }

  # automatically share all the nfs mounts on boot and unshare during shutdown
  file {
    '/etc/default/zfs':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/wr/default-zfs';
  }

  # mlocate is a waste for resources
  package {
    'mlocate':
      ensure  => absent,
  }

  # Configuration for squid-deb-proxy
  file {
    '/pool/cache/squid-deb-proxy':
      ensure  => directory,
      owner   => 'proxy',
      group   => 'proxy',
      mode    => '0755',
      require => Zfs['pool/cache'];
    '/var/cache/squid-deb-proxy':
      ensure => link,
      force  => true,
      target => '/pool/cache/squid-deb-proxy';
    '/etc/squid-deb-proxy/allowed-networks-src.acl.d/windriver-networks':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      require => Package['squid-deb-proxy'],
      notify => Service['squid-deb-proxy'],
      source => 'puppet:///modules/wr/windriver-networks';
    '/etc/squid-deb-proxy/mirror-dstdomain.acl.d/mirror-dstdomain':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      require => Package['squid-deb-proxy'],
      notify => Service['squid-deb-proxy'],
      source => 'puppet:///modules/wr/mirror-dstdomain';
  }
  package {
    'squid-deb-proxy':
      ensure => installed,
      require => File['/var/cache/squid-deb-proxy'];
  }
  service {
    'squid-deb-proxy':
      ensure    => running,
      require   => [ Package['squid-deb-proxy'], File['/var/cache/squid-deb-proxy']];
  }
  exec {
    'allow_all_mirror_access':
      command => '/bin/sed -i \'s/http_access deny !to_archive_mirrors/http_access allow !to_archive_mirrors/\' /etc/squid-deb-proxy/squid-deb-proxy.conf',
      onlyif  => '/bin/grep -q \'http_access deny !to_archive_mirrors\' /etc/squid-deb-proxy/squid-deb-proxy.conf',
      notify  => Service['squid-deb-proxy'];
  }

  include ::profile::mesos::wrlbuild

  file {
    '/home/wrlbuild/':
      ensure => directory,
      owner  => wrlbuild,
      group  => wrlbuild,
      mode   => '0755';
    '/home/wrlbuild/.ssh':
      ensure => directory,
      owner  => wrlbuild,
      group  => wrlbuild,
      mode   => '0700';
    '/git/managed_builds':
      ensure => directory,
      owner  => wrlbuild,
      group  => users,
      mode   => '0775';
  }

  # collect the ssh public keys for all the mesos slave wrlbuild users
  # returns a hash of hostname => { sshpubkey_wrlbuild => key }
  $sshpubkeys = query_facts('Class["mesos::slave"]',['sshpubkey_wrlbuild'])

  # some inline template magic. Loop over the hash and insert the key text
  # into the puppet array named key
  $keys = []
  $disard_me = inline_template('<%
@sshpubkeys.to_a.sort.each do |host,fact_hash|
  @keys << fact_hash[\'sshpubkey_wrlbuild\'].chomp
end
%>')

  wr::extract_key {
    $keys:
      user => 'wrlbuild'
  }

  # add keys so wwang and gzhou1 can make git dirs on fileservers
  ssh_authorized_key {
    'wwang0_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('wwang0'),
      type   => 'ssh-dss';
    'gzhou1_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('gzhou1'),
      type   => 'ssh-rsa';
    'ywei_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('ywei'),
      type   => 'ssh-dss';
  }

  # These tools are used to post-process managed build feeds for release
  package {
    ['rdfind', 'symlinks']:
      ensure  => present,
      require => Class['wr::common::repos'];
  }

  # file server is third mesos master in HA setup in Alameda DC
  if $::hostname == 'ala-lpdfs01' {
    include ::profile::mesos::master
  }
}
