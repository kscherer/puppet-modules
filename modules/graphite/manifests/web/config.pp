# Class: graphite
#
# This module manages graphite
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class graphite::web::config ($time_zone = undef){

  file {'local_settings.py':
    ensure    => file,
    path      => '/etc/graphite-web/local_settings.py',
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    notify    => Service['httpd'],
    content   => template('graphite/local_settings.py.erb');
  'graphite_http_conf':
    ensure  => 'present',
    path    => '/etc/httpd/conf.d/graphite-web.conf',
    mode    => '0644',
    owner   => root,
    group   => root;
  }

  include apache
  include apache::mod::wsgi

  # attempt to manage graphite apache config using puppet instead of package default
  # apache::vhost {
  #   "graphite-${::certname}":
  #     port                        => '80',
  #     alias                       =>
  #     [{'/media/'=> '/usr/lib/python2.6/site-packages/django/contrib/admin/media/' } ],
  #     docroot                     => '/usr/share/graphite/webapp',
  #     wsgi_import_script          => '/usr/share/graphite/graphite-web.wsgi',
  #     wsgi_import_script_options  =>
  #     { process-group             => '%{GLOBAL}',
  #     application-group           => '%{GLOBAL}' },
  #     wsgi_script_aliases         => { '/' => '/usr/share/graphite/graphite-web.wsgi' },
  #     directories                 =>
  #     [{path => '/content/', provider => 'location', handler => 'None'},
  #      {path => '/media/', provider => 'location', handler => 'None'}],
  # }
}
