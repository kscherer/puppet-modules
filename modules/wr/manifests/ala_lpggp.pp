#
class wr::ala_lpggp {
  include profile::nis
  include git
  include yocto

  Class['redhat'] -> Class['yocto']
  Class['redhat'] -> Class['git']

  if $::hostname == 'ala-lpggp2' {
    file {
      '/lpg-build':
        ensure => link,
        target => '/ala-lpggp22';
    }
  }
  if $::hostname == 'ala-lpggp3' {
    file {
      '/lpg-build':
        ensure => link,
        target => '/ala-lpggp32';
    }
  }

  package {
    ['quilt', 'wiggle']:
      ensure => 'latest';
  }


  file {
    [ "/${::hostname}1", "/${::hostname}2/"]:
      ensure => 'directory',
      group  => 'users',
      mode   => '0777';
  }

  motd::register{
    'ala-lpggp':
      content => "This machine is for Linux Products developers manual compiles.
It is not to be used for automated testing, automated builds or
other uses. Please limit compiles to --enable-jobs=5.
Use /${::hostname}[1-2] as local storage.
It is not backed up, make sure you have a secure copy
of your data.  Clean up after yourself, this F/S will be cleaned
up periodically.";
  }

  if $::hostname == 'ala-lpggp4' {
    file {
      ['/mnt/ala-mirror', '/home/svc-mirror']:
        ensure => directory;
    }
    mount {
      '/mnt/ala-mirror':
        ensure  => mounted,
        device  => 'ala-lpgnas1:/vol/ala_mirror',
        atboot  => true,
        fstype  => 'nfs',
        options => 'rw',
        require => File['/mnt/ala-mirror'];
      '/home/svc-mirror':
        ensure  => mounted,
        device  => 'ala-nas2:/vol/vol0/UNIX-Home/svc-mirror',
        atboot  => true,
        fstype  => 'nfs',
        options => 'rw',
        require => File['/home/svc-mirror'];
    }

    include rsync::server
    rsync::server::module{
      'centos':
        path => '/mnt/ala-mirror/mirror/centos',;
      'epel':
        path => '/mnt/ala-mirror/mirror/epel';
      'puppetlabs':
        path => '/mnt/ala-mirror/mirror/puppetlabs';
      'ubuntu':
        path => '/mnt/ala-mirror/mirror/ubuntu.com/ubuntu';
    }
  }
}
