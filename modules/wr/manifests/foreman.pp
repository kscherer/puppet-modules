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
    'delete_foreman_reports':
      ensure  => absent,
      user    => 'root',
      hour    => '0',
      command => 'foreman-rake reports:expire days=1 status=0; foreman-rake reports:expire days=7';
  }

}
