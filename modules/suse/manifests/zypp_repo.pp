#eliminate common fields amoung repo definitions
define suse::zypp_repo( $baseurl, $enabled = '1' ){

  zypprepo {
    $name:
      baseurl     => $baseurl,
      descr       => $name,
      enabled     => $enabled,
      autorefresh => '1',
      gpgcheck    => '1',
      gpgkey      => "${baseurl}/repodata/repomd.xml.key";
  }

  #this is necessary to keep puppet from deleting the repo files
  file {
    "/etc/zypp/repos.d/${name}.repo":
      ensure => file;
  }
}
