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

  #Setup user for python-rq and python-rq-dashboard
  user {
    'rq':
      ensure     => present,
      groups     => 'rq',
      home       => '/home/rq',
      shell      => '/bin/bash',
      managehome => true,
      password   => '$6$YTdVKDWvBu6$6ptIEV1e5cAKCq8weSWXEMwJugEq/xzG0.WzNDSHTSk5QbQUJy4bDPYPwU1ZE8jBkGiOzPrUogwSvS1dBbyuU0';
  }

  group {
    'rq':
      ensure => present;
  }

  ssh_authorized_key {
    'kscherer_desktop_rq':
      ensure => 'present',
      user   => 'rq',
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    'kscherer_home_rq':
      ensure => 'present',
      user   => 'rq',
      key    => hiera('kscherer@helix'),
      type   => 'ssh-rsa';
  }

  file {
    '/home/rq/.bashrc':
      ensure => present,
      owner  => 'rq',
      group  => 'rq',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/rq/.aliases':
      ensure => present,
      owner  => 'rq',
      group  => 'rq',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/rq/.bash_profile':
      ensure  => present,
      owner   => 'rq',
      group   => 'rq',
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }

  #This installs python-pip
  include python

  python::pip {
    'rq':
      ensure       => present,
      owner        => 'rq',
      environment  => 'HOME=/home/rq',
      install_args => '--user --build=/home/rq/.pip/build';
    'rq-dashboard':
      ensure       => present,
      owner        => 'rq',
      environment  => 'HOME=/home/rq',
      install_args => '--user --build=/home/rq/.pip/build';
    'jira-python':
      ensure       => present,
      owner        => 'rq',
      environment  => 'HOME=/home/rq',
      install_args => '--user --build=/home/rq/.pip/build';
  }

  #Setup supervisord to monitor worker process
  include supervisord

  supervisord::program { 'rqworker':
    command    => '/home/rq/.local/bin/rqworker jira-git',
    user       => 'rq',
    numprocs   => '1',
    stopsignal => 'TERM',
    directory  => '/home/rq/wr-jira-integration';
  }
}
