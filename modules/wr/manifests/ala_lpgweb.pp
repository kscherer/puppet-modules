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
  file_line {
    'set_domain':
      path   => '/etc/postfix/main.cf',
      line   => 'mydomain = wrs.com',
      notify => Service['postfix'];
    'set_relayhost':
      path   => '/etc/postfix/main.cf',
      line   => 'relayhost = prod-webmail.wrs.com',
      notify => Service['postfix'];
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

  supervisord::program {
    'layerindex_gunicorn':
      command    => 'python manage.py run_gunicorn 127.0.0.1:8001',
      user       => 'oelayer',
      directory  => '/home/oelayer/layerindex-web';
  }

  service {
    'mpt-statusd':
      ensure    => stopped,
      hasstatus => false;
  }

  include zookeeper
}
