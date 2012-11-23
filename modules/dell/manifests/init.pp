#
class dell {
  $mirror = hiera('mirror')
  $dell_repo = '/etc/yum.repos.d/dell-omsa-repository.repo'
  exec {
    'dell_repo':
      command => "wget -q -O - http://${mirror}/mirror/dell/hardware/latest/bootstrap.sh | bash",
      creates => $dell_repo;
  }

  #need this to ensure dell repo is not deleted
  file {
    $dell_repo:
      ensure  => file,
      require => Exec['dell_repo'];
  }
}
