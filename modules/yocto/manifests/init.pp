#
class yocto {
  $packages = hiera_array('packages')
  package {
    $packages:
      ensure => 'installed';
  }
}
