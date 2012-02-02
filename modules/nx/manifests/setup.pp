#
define nx::setup {

  #this directory is created by the subclasses like
  #yow-blades and yow-hostel
  $nx_builddir="/home/nxadm/nx/${::hostname}.${name}"

  Exec {
    cwd     => $nx_builddir,
    require => [ File[$nx_builddir], User['nxadm'] ],
    user    => 'nxadm',
  }

  #clone all the needed repos to run nx
  exec {
    "clone_bin_repo_$name":
      command => 'git clone git://yow-git.ottawa.wrs.com/bin',
      unless  => "test -d $nx_builddir/bin";
    "clone_nxrc_repo_$name":
      command => 'git clone git://ala-git.wrs.com/users/buildadmin/nxrc_files',
      unless  => "test -d $nx_builddir/nxrc_files";
    "clone_nxconfigs_repo_$name":
      command => 'git clone git://ala-git.wrs.com/users/buildadmin/configs',
      unless  => "test -d $nx_builddir/configs";
    "clone_notxylo_repo_$name":
      command => 'git clone git://ala-git.wrs.com/users/paul/notxylo',
      unless  => "test -d $nx_builddir/notxylo";
  }

  #make a link to the service name
  file {
    "/etc/init.d/nx_instance.$name":
      ensure => link,
      user   => root,
      group  => root,
      mode   => '0755',
      notify => Service["nx_instance.$name"],
      target => '/etc/init.d/nx_instance';
  }

  #actually run the service. Note this will create
  #create the wrlinux-x repo the first time it runs
  service {
    "nx_instance.$name":
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [ Exec["clone_bin_repo_$name"],
                      Exec["clone_nxrc_repo_$name"],
                      Exec["clone_nxconfigs_repo_$name"],
                      Exec["clone_notxylo_repo_$name"],
                      File["/etc/init.d/nx_instance.$name"] ];
  }
}
