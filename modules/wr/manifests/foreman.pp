#
class wr::foreman {
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
