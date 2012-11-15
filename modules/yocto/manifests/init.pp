#
class yocto {

  #workaround for lack of array support in ensure_resource
  define yocto::ensure_package() {
    if ! defined(Package[$name]) {
      ensure_resource( 'package', $name, {'ensure' => 'installed' })
    }
  }

  $packages = hiera_array('packages')
  yocto::ensure_package { $packages: }
}
