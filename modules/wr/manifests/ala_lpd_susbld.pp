#
class wr::ala_lpd_susbld {
  include profile::nis

  ssh_authorized_key {
    'pkennedy_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('pkennedy@linux-y9cs.site'),
      type   => 'ssh-dss';
    'wenzong_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
    'buildadmin_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('buildadmin@ala-blade9'),
      type   => 'ssh-rsa';
  }

  service {
    'httpd':
      ensure => running,
      enable => true,
  }

  file {
    '/mnt/ala-lpdfs01':
      ensure  => directory,
      owner   => 'svc-bld',
      group   => 'users',
      require => Class['nis'],
  }

  mount {
    '/mnt/ala-lpdfs01':
      ensure   => mounted,
      atboot   => true,
      device   => 'ala-lpdfs01:/pool/sustaining',
      fstype   => 'nfs',
      options  => 'bg,vers=3,nointr,timeo=600,_netdev',
      require  => File['/mnt/ala-lpdfs01'],
      remounts => true;
  }

  if $::osfamily == 'Debian' {
    include docker
    # some developers are more comfortable with vnc
    ensure_packages( ['screen', 'wiggle', 'expect', 'quilt', 'tmux', 'curl',
                      'wget','tightvncserver', 'xfsprogs', 'vim-nox'])

    #enable running docker and runqemu using sudo
    sudo::conf {
      'lpg':
        source  => 'puppet:///modules/wr/sudoers.d/lpg';
    }
  } else {
    #clearcase installation depends on this specific kernel
    package {
      'kernel':
        ensure => '2.6.18-194.el5';
    }
  }
}
