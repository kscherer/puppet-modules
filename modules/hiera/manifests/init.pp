#
class hiera (
  $hierarchy  = [],
  $backends   = ['yaml'],
  $logger     = 'console',
  $hiera_yaml = '/etc/puppet/hiera.yaml',
  $datadir    = '/etc/puppet/hieradata',
  $owner      = 'puppet',
  $group      = 'puppet'
  ) {
    File {
      owner => $owner,
      group => $group,
      mode  => '0644',
    }

    # Template uses $hierarchy, $datadir, $backends, $logger
    file { $hiera_yaml:
      ensure  => present,
      require => Package['hiera'],
      content => template('hiera/hiera.yaml.erb'),
    }

    # Symlink for hiera command line tool
    file { '/etc/hiera.yaml':
      ensure => symlink,
      target => $hiera_yaml,
    }

    package {
      'hiera':
        ensure => latest;
    }
}
