#Install the base OpenManage software for managing Dell Hardware
class dell {
  $mirror = hiera('mirror')
  $dell_repo = '/etc/yum.repos.d/dell-omsa-repository.repo'

  #Since dell repo is more complicated due to hardware model, etc.
  #use the supplied bootstrap script to enable local mirror
  exec {
    'dell_repo':
      command => "wget -q -O - http://${mirror}/mirror/dell/hardware/latest/bootstrap.cgi | bash",
      creates => $dell_repo;
  }

  #need this to ensure dell repo is not deleted
  file {
    $dell_repo:
      ensure  => file,
      require => Exec['dell_repo'];
  }

  #package has to depend on file, not yum repo
  package {
    ['srvadmin-base','srvadmin-storage','srvadmin-server-cli','srvadmin-storage-cli']:
      ensure  => latest,
      notify  => Service['dataeng'],
      require => File[$dell_repo];
  }

  #This service is necessary to run omreport cli tool
  service {
    'dataeng':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package['srvadmin-base'];
  }
}
