#
class yocto {

  #workaround for lack of array support in ensure_resource
  define yocto::ensure_package() {
    ensure_resource( 'package', $name, {'ensure' => 'installed' })
  }

  $packages = hiera_array('packages')
  yocto::ensure_package { $packages: }

  #yocto machines are being used for development to debug failures are need
  #the following packages
  yocto::ensure_package { 'gdb': }
}
