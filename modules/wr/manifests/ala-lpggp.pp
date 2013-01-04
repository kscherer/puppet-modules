#
class wr::ala-lpggp inherits wr::ala-common {
  class { 'yocto': }
  class { 'git': }
  Class['redhat'] -> Class['yocto']
  Class['redhat'] -> Class['git']

  if $::hostname == 'ala-lpggp2.wrs.com' {
    file {
      '/lpg-build':
        ensure => link,
        target => '/ala-lpggp22';
    }
  }
  if $::hostname == 'ala-lpggp3.wrs.com' {
    file {
      '/lpg-build':
        ensure => link,
        target => '/ala-lpggp32';
    }
  }

  package {
    'quilt':
      ensure => 'latest';
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
  file {
    [ "/${::hostname}1", "/${::hostname}2/"]:
      ensure => 'directory',
      group  => 'users',
      mode   => '0777';
  }

  if $::hostname == 'ala-lpggp1' {
    #buildadmin user is a nis account, but without a nfs home directory.
    file {
      '/home/buildadmin':
        ensure  => directory,
        owner   => 'buildadmin',
        group   => 'buildadmin',
        require => Class['nis'],
        mode    => '0755';
      '/home/buildadmin/.ssh':
        ensure => directory,
        owner  => 'buildadmin',
        group  => 'buildadmin',
        mode   => '0700';
    }

    ssh_authorized_key {
      'pkennedy_buildadmin':
        ensure  => 'present',
        user    => 'buildadmin',
        key     => extlookup('pkennedy@linux-y9cs.site'),
        require => File['/home/buildadmin/.ssh'],
        type    => 'ssh-dss';
      'wenzong_buildadmin':
        ensure  => 'present',
        user    => 'buildadmin',
        key     => extlookup('wfan@pek-wenzong-fan'),
        require => File['/home/buildadmin/.ssh'],
        type    => 'ssh-dss';
      'kscherer_windriver_buildadmin':
        ensure  => 'present',
        user    => 'buildadmin',
        key     => extlookup('kscherer@yow-kscherer-l1'),
        require => File['/home/buildadmin/.ssh'],
        type    => 'ssh-dss';
      'kscherer_home_buildadmin':
        ensure  => 'present',
        user    => 'buildadmin',
        key     => extlookup('kscherer@helix'),
        require => File['/home/buildadmin/.ssh'],
        type    => 'ssh-rsa';
    }

    sudo::conf {
      'admin':
        source  => 'puppet:///modules/wr/sudoers.d/admin';
    }

    host {
      'ala-lpgnas1':
        ip           => '147.11.105.11',
        host_aliases => 'ala-lpgnas1.wrs.com';
      'ala-lpgnas2':
        ip           => '147.11.105.12',
        host_aliases => 'ala-lpgnas2.wrs.com';
    }

    file {
      '/stored_builds':
        ensure  => directory,
        owner   => 'buildadmin',
        group   => 'buildadmin',
        require => Class['nis'];
      '/ala-lpggp12/buildarea':
        ensure  => directory,
        owner   => 'buildadmin',
        group   => 'buildadmin';
      '/buildarea':
        ensure => link,
        target => '/ala-lpggp12/buildarea';
    }

    mount {
      '/stored_builds':
        ensure   => mounted,
        atboot   => true,
        device   => 'ala-lpgnas2:/vol/vol1',
        fstype   => 'nfs',
        options  => 'bg,vers=3,nointr,timeo=600,_netdev',
        require  => File['/stored_builds'],
        remounts => true;
    }
  }
}
