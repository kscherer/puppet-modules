#
class wr::ala_lpgweb {
  include profile::nis

  #setup mail
  include ssmtp
  ensure_resource('package', 'heirloom-mailx', {'ensure' => 'latest'})

  #some packages needed to run perl CQ scripts
  ensure_resource('package', 'libdate-manip-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'liburi-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libxml-simple-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libxml-twig-perl', {'ensure' => 'latest'})

  #some packages needed by jch's personal scripts
  ensure_resource('package', 'libnet-ldap-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'liblocale-subcountry-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libspreadsheet-read-perl', {'ensure' => 'latest'})

  #setup redis for python-rq
  include redis

  define webuser( $password ) {
    user {
      $name:
        ensure     => present,
        groups     => $name,
        home       => "/home/${name}",
        shell      => '/bin/bash',
        managehome => true,
        password   => $password;
    }

    group {
      $name:
        ensure => present;
    }

    ssh_authorized_key {
      "kscherer_desktop_${name}":
        ensure => 'present',
        user   => $name,
        key    => hiera('kscherer@yow-kscherer-d1'),
        type   => 'ssh-rsa';
      "kscherer_home_${name}":
        ensure => 'present',
        user   => $name,
        key    => hiera('kscherer@helix'),
        type   => 'ssh-rsa';
    }

    file {
      "/home/${name}/.bashrc":
        ensure => present,
        owner  => $name,
        group  => $name,
        mode   => '0755',
        source => 'puppet:///modules/wr/bashrc';
      '/home/oelayer/.aliases':
        ensure => present,
        owner  => $name,
        group  => $name,
        mode   => '0755',
        source => 'puppet:///modules/wr/aliases';
      "/home/${name}/.bash_profile":
        ensure  => present,
        owner   => $name,
        group   => $name,
        content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
    }
  }

  webuser {
    'rq':
      password   => '$6$YTdVKDWvBu6$6ptIEV1e5cAKCq8weSWXEMwJugEq/xzG0.WzNDSHTSk5QbQUJy4bDPYPwU1ZE8jBkGiOzPrUogwSvS1dBbyuU0';
  }

  #This installs python-pip
  include python

  #define to reduce boilerplate
  define pip_package ( $owner ) {
    python::pip {
      $name:
        ensure       => present,
        owner        => $owner,
        environment  => "HOME=/home/${owner}",
        install_args => "--user --build=/home/${owner}/.pip/build";
    }
  }

  pip_package {
    ['rq', 'rq-dashboard', 'jira-python' ]:
      owner => 'rq';
  }

  #Setup supervisord to monitor worker process
  include supervisord

  supervisord::program {
    'rqworker':
      command    => '/home/rq/.local/bin/rqworker jira-git',
      user       => 'rq',
      numprocs   => '1',
      directory  => '/home/rq/wr-jira-integration';
    'rq-dashboard':
      command    => '/home/rq/.local/bin/rq-dashboard',
      user       => 'rq',
      numprocs   => '1',
      directory  => '/home/rq/',
      require    => Vcsrepo['wr-jira-integration'];
    'rqworker-wr-rq':
      command    => '/home/rq/.local/bin/rqworker wr-rq',
      user       => 'rq',
      numprocs   => '1',
      directory  => '/home/rq/wr-rq',
      require    => Vcsrepo['wr-rq'];
  }

  vcsrepo {
    'wr-jira-integration':
      ensure   => 'latest',
      path     => '/home/rq/wr-jira-integration',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/lpd-ops/wr-jira-integration.git',
      user     => 'rq',
      revision => 'master';
    'wr-rq':
      ensure   => 'latest',
      path     => '/home/rq/wr-rq',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/lpd-ops/wr-rq.git',
      user     => 'rq',
      revision => 'master';
  }

  #require apache to display exported process docs
  include apache
  apache::vhost {
    'ala-lpgweb2.wrs.com':
      port    => 80,
      docroot => '/var/www/';
  }

  #make link into rendered docs
  file {
    '/var/www/wr-process':
      ensure => link,
      target => '/home/rq/wr-process';
  }

  #plantuml requires java
  include java

  #setup for open embedded layer index web app
  webuser {
    'oelayer':
      password => '$6$JE9EdCoGh$SgIhKWioQFsTrbTLZ05MMXXxfV/err6ZNksOSSluUhg6irGg.9b52fo0R.ydaXOVS8GcKWoU2Z6wm.FFjWcYv0';
  }

  pip_package {
    ['django', 'South', 'django-registration', 'django-reversion',
      'django-reversion-compare', 'django-simple-captcha', 'django-nvd3',
      'GitPython']:
      owner => 'oelayer';
  }

  vcsrepo {
    'openembedded_layerindex':
      ensure   => 'present',
      path     => '/home/oelayer/layerindex-web',
      provider => 'git',
      source   => 'git://git.yoctoproject.org/layerindex-web',
      user     => 'oelayer',
      revision => 'master';
  }
}
