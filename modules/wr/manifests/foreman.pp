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
  realize( RedHat::Yum_repo['foreman'] )
  package {
    'foreman-proxy':
      ensure => installed;
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
}
