# Install nfs server and service
class nfs::server {
  if $::operatingsystem == 'Ubuntu' {
    package {
      'nfs-kernel-server':
        ensure  => installed,
        require => File['/etc/exports'];
    }

    service {
      'nfs-kernel-server':
        ensure    => running,
        require   => [ Package['nfs-kernel-server'], File['/etc/exports']];
    }
  }

  concat {
    '/etc/exports':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Service['nfs-kernel-server'];
  }

  concat::fragment {
    'base_nfs_exports':
      target  => '/etc/exports',
      content => '/mnt localhost(ro)\n',
      order   => '01'
  }
}
