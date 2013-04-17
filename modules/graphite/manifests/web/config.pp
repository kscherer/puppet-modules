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
}
