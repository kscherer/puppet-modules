#
class wr::ala-lpd-puppet {
  class {'wr::dns': }
  -> class { 'redhat': }
  -> class { 'ntp': }
  -> class { 'wr::activemq': broker_name => 'ala-broker' }
  -> class { 'wr::master': }
  -> class { 'git::stomp_listener': }
  -> class { 'graphite': }

  include apache::mod::wsgi

  Class['redhat'] -> class { 'nrpe': }

  include nagios
  include nagios::target
  include nagios::nsca::server

  graphite::carbon::storage {
    'default_10s_for_2weeks':
      pattern    => '.*',
      retentions => '10s:14d',
  }

  #concat is another possible extension point
  concat::fragment {
    'cpu-aggregrate':
      target  => '/etc/carbon/aggregation-rules.conf',
      order   => 1,
      source  => 'puppet:///modules/wr/cpu-aggregation.conf';
  }

  $foreman_url = hiera('foreman_url')
  $foreman_ssl_ca = hiera('foreman_ssl_ca')
  $foreman_ssl_cert = hiera('foreman_ssl_cert')
  $foreman_ssl_key = hiera('foreman_ssl_key')

  $inventory_upload = '/var/lib/puppet/foreman_upload_inventory.rb'

  file {
    '/usr/lib/ruby/site_ruby/1.8/puppet/reports/foreman.rb':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      content => template('wr/foreman.rb.erb');
    $inventory_upload:
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0755',
      content => template('wr/foreman_upload_inventory.rb.erb');
  }

  cron {
    'upload_inventory_to_foreman':
      ensure  => present,
      command => $inventory_upload,
      user    => puppet,
      minute  => '*/5',
      require => File[$inventory_upload];
  }
}
