#
class wr::yow-lpggp {
  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  include profile::nis
  include git
  include apache

  package {
    [ 'quilt', 'wiggle', 'createrepo', 'yum-utils', 'fuse', 'fuse-libs',
      'python26', 'mrepo', 'python-ssl', 'mirrormanager-client']:
      ensure => 'latest';
  }

  motd::register{
    'yow-lpggp':
      content => "This machine is for Linux Products developers manual
compiles.  It is not to be used for automated testing, automated
builds or other uses. Please limit compiles to --enable-jobs=5.
Use /${::hostname}1 as local storage.  It is not backed up, make
sure you have a secure copy of your data.  Clean up after
yourself, this F/S will be cleaned up periodically.";
  }

  file {
    ['/mnt/yow-mirror', '/home/svc-mirror']:
      ensure => directory;
    # this is not enough. Need fuse-iso package from rpmforge
    # and set world execute permissions on /bin/fusermount
    '/etc/fuse.conf':
      ensure  => present,
      content => 'user_allow_other';
  }

  mount {
    '/mnt/yow-mirror':
      ensure  => mounted,
      device  => 'yow-lpgnas1:/vol/yow_mirror',
      atboot  => true,
      fstype  => 'nfs',
      options => 'rw',
      require => File['/mnt/yow-mirror'];
    '/home/svc-mirror':
      ensure  => mounted,
      device  => 'yow-nas2:/vol/vol1/UNIX-Home/svc-mirror',
      atboot  => true,
      fstype  => 'nfs',
      options => 'rw',
      require => File['/home/svc-mirror'];
  }

  if $::hostname == 'yow-lpggp2' {
    file {
      '/etc/mrepo.conf':
        ensure => link,
        target => '/home/svc-mirror/mirror-configs/mrepo/mrepo.conf';
      '/etc/ubumirror.conf':
        ensure => link,
        target => '/home/svc-mirror/mirror-configs/ubumirror.conf';
      '/etc/mirrormanager-client/report_mirror.conf':
        ensure => link,
        target => '/home/svc-mirror/mirror-configs/report_mirror.conf';
      '/home/svc-mirror/etc/common':
        ensure => link,
        target => '/home/svc-mirror/mirror-configs/common';
      '/home/svc-mirror/etc/ftpsync.conf':
        ensure => link,
        target => '/home/svc-mirror/mirror-configs/ftpsync.conf';
    }

    cron {
      'dell_linux_repo':
        ensure      => present,
        command     => ' /usr/bin/rsync -avHz --delete --delete-delay linux.dell.com::repo/hardware /mnt/yow-mirror/mirror/dell > /mnt/yow-mirror/mirror/log/dell_repo.log',
        environment => ['HOME=/home/svc-mirror',
                        'PATH=/usr/bin:/bin/:/sbin/:/usr/sbin',
                        'MAILTO=konrad.scherer@windriver.com'],
        user        => 'svc-mirror',
        hour        => '5',
        minute      => '0';
      'mrepo':
        ensure  => present,
        command => '/home/svc-mirror/mirror-configs/mrepo/mrepo -ug > /mnt/yow-mirror/mirror/log/mrepo.log 2>&1',
        user    => 'svc-mirror',
        hour    => '19',
        minute  => '0';
      'mrepo_logrotate':
        ensure  => present,
        command => '/usr/sbin/logrotate -s /mnt/yow-mirror/mirror/log/logrotate.status /home/svc-mirror/mirror-configs/mrepo/mrepo.logrotate',
        user    => 'svc-mirror',
        hour    => '12',
        minute  => '0';
      'mirror-rsync':
        ensure  => present,
        command => 'https_proxy=http://128.224.144.3:9090 /home/svc-mirror/mirror-rsync/mirror-fedora > /mnt/yow-mirror/mirror/log/mirror-rsync.log',
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
      'debian':
        ensure  => present,
        command => '/home/svc-mirror/mirror-configs/ftpsync',
        user    => 'svc-mirror',
        hour    => '22',
        minute  => '0';
      'make_iso_links':
        ensure  => present,
        command => '/home/svc-mirror/mirror-configs/mk_iso_links.sh',
        user    => 'svc-mirror',
        hour    => '6',
        minute  => '0';

    }

    #dell repo needs to be able to exec cgi scripts
    apache::vhost {
      "mirror-${::hostname}":
        port             => '80',
        docroot          => '/var/www/html',
        directories      =>
        [{path           => '/var/www/html',
          options        => ['Indexes', 'FollowSymLinks', 'MultiViews', 'ExecCGI'],
          allow_override => ['None'],
          order          => ['Allow','Deny'],
          allow          => 'from all',
          addhandlers    => [{ handler => 'cgi-script', extensions => ['.cgi']}],
          }],
    }
  }
}
