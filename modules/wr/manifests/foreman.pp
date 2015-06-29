#
class wr::foreman {
  $foreman_url = hiera('foreman_url')
  $foreman_ssl_ca = hiera('foreman_ssl_ca')
  $foreman_ssl_cert = hiera('foreman_ssl_cert')
  $foreman_ssl_key = hiera('foreman_ssl_key')

  $foreman_external_node = '/etc/puppet/foreman_external_node.rb'

  file {
    '/usr/lib/ruby/site_ruby/1.8/puppet/reports/foreman.rb':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      content => template('wr/foreman.rb.erb');
    $foreman_external_node:
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0755',
      content => template('wr/foreman_external_node.rb.erb');
  }

  cron {
    'upload_inventory_to_foreman':
      ensure  => present,
      command => "${foreman_external_node} --push-facts",
      user    => puppet,
      minute  => '*/5';
  }

  #add foreman repo to install puppet ca smart proxy
  package {
    'foreman-proxy':
      ensure  => installed,
      require => Yumrepo['foreman'];
  }

  #smart proxy needs sudo access to remove certs
  include sudo
  sudo::conf {
    'puppetca-proxy':
      source  => 'puppet:///modules/wr/sudoers.d/puppetca-proxy';
  }

  user {
    'foreman-proxy':
      ensure => present,
      groups => 'puppet';
  }

  group {
    'foreman-proxy':
      ensure => present;
  }

  exec {
    'enable_puppetca_proxy':
      command => '/bin/sed -i \'s/puppetca: false/puppetca: true/\' /etc/foreman-proxy/settings.yml',
      unless  => '/bin/grep -q \'puppetca: true\' /etc/foreman-proxy/settings.yml',
      notify  => Service['foreman-proxy'];
  }

  service {
    'foreman-proxy':
      ensure    => running,
      hasstatus => true,
      enable    => true;
  }

  file {
    '/etc/puppet/autosign.conf':
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0664';
  }
}
