#eliminate common fields amoung repo definitions
define redhat::yum_repo( $baseurl, $enabled = '1', $repo_gpgkey = undef ){
  $real_gpgcheck = $repo_gpgkey ? {
    undef   => '0',
    default => '1',
  }

  yumrepo {
    $name:
      baseurl  => $baseurl,
      descr    => $name,
      enabled  => $enabled,
      gpgcheck => $real_gpgcheck,
      gpgkey   => $repo_gpgkey;
  }

  #this is necessary to keep puppet from deleting the repo files
  file {
    "/etc/yum.repos.d/${name}.repo":
      ensure => file;
  }
}
