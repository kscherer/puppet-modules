#
class nfs::client{
  #require nfs to find mount prebuilts
  case $::operatingsystem {
    'Ubuntu'   : { $nfs_package_name = 'nfs-common' }
    'OpenSuSE' : { $nfs_package_name = 'nfs-client' }
    'SLED' : {
      if $::operatingsystemrelease == '10.2' {
        $nfs_package_name = 'nfs-utils'
      } else {
        $nfs_package_name = 'nfs-client'
      }
    }
    default : { $nfs_package_name = 'nfs-utils' }
  }

  package {
    $nfs_package_name:
      ensure => present;
  }
}
