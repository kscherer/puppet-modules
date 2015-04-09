#
class wr::ala_lpgweb {
  include profile::nis

  #some packages needed to run perl CQ scripts
  ensure_resource('package', 'libdate-manip-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'liburi-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libxml-simple-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libxml-twig-perl', {'ensure' => 'latest'})

  #some packages needed by jch's personal scripts
  ensure_resource('package', 'libnet-ldap-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'liblocale-subcountry-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libspreadsheet-read-perl', {'ensure' => 'latest'})

  #by default ssmtp is installed but times out with long cron scripts
  #so use postfix but it requires configuration
  ensure_resource('package', 'postfix', {'ensure' => 'installed' })
  ensure_resource('package', 'python-yaml', {'ensure' => 'installed' })

  # plantuml can use graphviz make some neat pictures
  ensure_resource('package', 'graphviz', {'ensure' => 'installed' })

  augeas {
    'postfix.main.cf':
      context => '/files/etc/postfix/main.cf',
      changes => [
                  'set myorigin "windriver.com"',
                  'set relayhost "prod-webmail.windriver.com"',
                  'set inet_interfaces "loopback-only"',
                  'set masquerade_domains "windriver.com wrs.com"',
                  'clear mydestination',
                  ],
      notify  => Service['postfix']
  }

  #Postfix service needs to be running to deliver mail
  service {
    'postfix':
      ensure => running,
      enable => true;
  }

  #setup redis for python-rq
  include redis

  wr::user {
    'rq':
      password   => '$6$YTdVKDWvBu6$6ptIEV1e5cAKCq8weSWXEMwJugEq/xzG0.WzNDSHTSk5QbQUJy4bDPYPwU1ZE8jBkGiOzPrUogwSvS1dBbyuU0';
  }

  #This installs python-pip
  include python

  wr::pip_userpackage {
    ['rq', 'rq-dashboard', 'jira-python' ]:
      owner => 'rq';
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
    'wr-buildscripts':
      ensure   => 'latest',
      path     => '/home/rq/wr-buildscripts',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/lpd-ops/wr-buildscripts.git',
      user     => 'rq',
      revision => 'master';
  }

  wr::upstart_conf {
    ['rqworker', 'rqworker-wr-rq', 'rq-dashboard', 'devbuild_watcher']:
  }

  $script = '/home/rq/wr-buildscripts/devbuild_queue_watcher.py'

  #not a real service, just a python script that looks like a service
  service {
    'devbuild_queue_watcher':
      ensure     => running,
      start      => "${script} start",
      stop       => "${script} stop",
      status     => "${script} status",
      restart    => "${script} restart",
      hasrestart => true,
      hasstatus  => true,
      enable     => manual,
      provider   => base,
      require    => Vcsrepo['wr-buildscripts'];
    'rqworker':
      ensure  => running,
      require => [Vcsrepo['wr-jira-integration'], File['/etc/init/rqworker.conf']];
    'rqworker-wr-rq':
      ensure  => running,
      require => [Vcsrepo['wr-rq'], File['/etc/init/rqworker-wr-rq.conf']];
    'rq-dashboard':
      ensure  => running,
      require => File['/etc/init/rq-dashboard.conf'];
    'devbuild_watcher':
      ensure  => running,
      require => [Vcsrepo['wr-buildscripts'], File['/etc/init/devbuild_watcher.conf']];
  }

  cron {
    'native_sstate_rebuild':
      ensure  => present,
      command => '/home/rq/wr-buildscripts/native_sstate_rebuild_enqueue.py',
      user    => 'rq',
      hour    => '20',
      minute  => '0';
    'wraxl_delete_temp_queues':
      ensure  => present,
      command => '/home/rq/wr-buildscripts/wraxl_delete_temp_queues.py',
      user    => 'rq',
      hour    => '22',
      minute  => '0';
    'ovp_lava_build':
      ensure  => present,
      command => '/home/rq/wr-buildscripts/ovp_lava_enqueue.py',
      user    => 'rq',
      hour    => '13',
      minute  => '0';
  }

  #require apache to display exported process docs
  include apache
  include apache::mod::proxy
  apache::vhost {
    'ala-lpgweb2.wrs.com':
      port       => 80,
      docroot    => '/var/www/',
      aliases    => [ { alias => '/static/',
                        path  => '/home/oelayer/layerindex-web/layerindex/static/' } ],
      proxy_pass => [ { 'path' => '/layerindex',
                        'url'  => 'http://127.0.0.1:8001/layerindex' }];
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
  wr::user {
    'oelayer':
      password => '$6$JE9EdCoGh$SgIhKWioQFsTrbTLZ05MMXXxfV/err6ZNksOSSluUhg6irGg.9b52fo0R.ydaXOVS8GcKWoU2Z6wm.FFjWcYv0';
  }

  wr::pip_userpackage {
    ['django', 'South', 'django-registration', 'django-reversion',
      'django-reversion-compare', 'django-simple-captcha', 'django-nvd3',
      'GitPython','pil', 'gunicorn']:
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

  cron {
    'update_layerindex':
      ensure  => present,
      command => '/usr/bin/python /home/oelayer/layerindex-web/layerindex/update.py > /home/oelayer/layerindex-update.log',
      user    => 'oelayer',
      hour    => '0',
      minute  => '0';
  }

  #use a postgresql database to hold layerindex info
  include postgresql::server

  postgresql::server::db { 'layerindex':
    user     => 'oelayer',
    password => postgresql_password('oelayer', 'oelayer'),
  }

  service {
    'mpt-statusd':
      ensure    => stopped,
      hasstatus => false;
  }

  include zookeeper

  wr::user {
    'errorweb':
      password   => '$5$BgyVYu6DgaQM2cEP$BO9AhcDlJRgvQWH5EkIuygrLMh37.Sl3YGtIffGwfT5';
  }
}
