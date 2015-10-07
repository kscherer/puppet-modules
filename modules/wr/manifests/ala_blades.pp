#
class wr::ala_blades {

  include profile::nxbuilder

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
    'root@ala-blade9':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade9'),
      type   => 'ssh-rsa';
    'root@ala-blade14':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade14'),
      type   => 'ssh-dss';
    'root@ala-blade17':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade17'),
      type   => 'ssh-rsa';
    'root@ala-blade25':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade25'),
      type   => 'ssh-rsa';
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

  host {
    'ala-lpgnas1-nfs':
      ensure       => absent,
      ip           => '172.17.136.110',
      host_aliases => 'ala-lpgnas1-nfs.wrs.com';
    'ala-lpgnas2-nfs':
      ensure       => absent,
      ip           => '172.17.136.114',
      host_aliases => 'ala-lpgnas2-nfs.wrs.com';
  }

  file {
    '/stored_builds':
      ensure  => directory,
      owner   => 'buildadmin',
      group   => 'buildadmin',
      require => Class['nis'],
  }

  if $::hostname == 'ala-blade1' {
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

    #Add buildadmin to sudoers
    sudo::conf {
      'xylo':
        source  => 'puppet:///modules/wr/sudoers.d/xylo';
    }
  }

  #some packages needed to run Xylo
  package {
    ['perl-XML-Simple','cvs','perl-Module-Manifest']:
      ensure  => installed,
  }

  #make sure latest Twig package is installed
  package {
    'perl-XML-Twig':
      ensure  => latest,
      require => Yumrepo['xylo'];
  }

  #To build 4.3 on ala-blades install required packages
  include wrlinux
}
