#
class wr::puppetcommander {

  file {
    '/etc/puppetcommander.cfg':
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/wr/puppetcommander.cfg';
    '/usr/sbin/puppetcommanderd':
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/puppetcommanderd';
    '/etc/init.d/puppetcommanderd':
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => template('wr/puppetcommander.init.erb');
    '/var/lib/puppet/log':
      ensure => directory,
      owner  => 'puppet',
      group  => 'puppet';
  }

  service {
    'puppetcommanderd':
      ensure  => running,
      enable  => true,
      require => [File['/etc/puppetcommander.cfg'],
                  File['/usr/sbin/puppetcommanderd'],
                  File['/etc/init.d/puppetcommanderd'],
                  File['/var/lib/puppet/log'] ];
  }

}
