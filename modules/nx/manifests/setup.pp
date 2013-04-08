#
define nx::setup( $notxylo_branch = 'master') {

  #this directory is created by the subclasses like
  #yow-blades and yow-hostel
  $nx_builddir="/home/nxadm/nx/${::hostname}.${name}"

  Exec {
    cwd     => $nx_builddir,
    require => User['nxadm'],
    user    => 'nxadm',
    group   => 'nxadm',
  }

  #clone all the needed repos to run nx
  exec {
    "clone_bin_repo_${name}":
      command => "git clone git://${::location}-git.wrs.com/bin",
      require => File[$nx_builddir],
      unless  => "test -d ${nx_builddir}/bin";
    "clone_nxrc_repo_${name}":
      command => 'git clone git://ala-git.wrs.com/users/buildadmin/nxrc_files',
      require => File[$nx_builddir],
      unless  => "test -d ${nx_builddir}/nxrc_files";
    "clone_nxconfigs_repo_${name}":
      command => 'git clone git://ala-git.wrs.com/users/buildadmin/configs',
      require => File[$nx_builddir],
      unless  => "test -d ${nx_builddir}/configs";
    "clone_notxylo_repo_${name}":
      command => "git clone --branch ${notxylo_branch} git://ala-git.wrs.com/users/paul/notxylo",
      require => File[$nx_builddir],
      unless  => "test -d ${nx_builddir}/notxylo";
  }

  #make a link to the service name
  file {
    "/etc/init.d/nx_instance.${name}":
      ensure => link,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      target => '/etc/init.d/nx_instance';
  }

  #actually run the service. Note this will create
  #create the wrlinux-x repo the first time it runs
  service {
    "nx_instance.${name}":
      ensure     => running,
      enable     => true,
      start      => "/etc/init.d/nx_instance.${name} start",
      stop       => "/etc/init.d/nx_instance.${name} stop",
      restart    => "/etc/init.d/nx_instance.${name} restart",
      status     => "/etc/init.d/nx_instance.${name} status",
      hasstatus  => true,
      hasrestart => true,
      require    => [ Exec["clone_bin_repo_${name}"],
                      Exec["clone_nxrc_repo_${name}"],
                      Exec["clone_nxconfigs_repo_${name}"],
                      Exec["clone_notxylo_repo_${name}"],
                      File["/etc/init.d/nx_instance.${name}"] ];
  }
}
