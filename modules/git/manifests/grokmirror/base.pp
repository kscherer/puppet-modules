#Install and manage grokmirror
class git::grokmirror::base {

  include git::params

  #On CentOS 5 this uses a special verison of GitPython for Python 2.6
  ensure_resource('package', $git::params::python_git, {'ensure' => 'installed' })

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease == '5' {
    #Grokmirror does not work with Python 2.4, so use EPEL python26
    ensure_resource('package', 'python26', {'ensure' => 'installed' })
  }

  vcsrepo {
    '/git/grokmirror':
      ensure   => 'latest',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/external/github.com.mricon.grokmirror.git',
      user     => 'git',
      revision => 'master';
  }
}
