#
class yocto {

  #workaround for lack of array support in ensure_resource
  define yocto::ensure_package() {
    ensure_resource( 'package', $name, {'ensure' => 'installed' })
  }

  $packages = hiera_array('packages')
  yocto::ensure_package { $packages: }

  #prevent accidental forkbombs, but builds with high parallelism
  #can generate more than default 1024 limit. So it is increased.
  if $::osfamily == 'RedHat' {
    file {
      '/etc/security/limits.d/90-nproc.conf':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => '* soft nproc 5000';
    }
  }
}
