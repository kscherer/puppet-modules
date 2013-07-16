#Install and manage grokmirror
class git::grokmirror::base {

  include git::params
  ensure_resource('package', $git::params::python_git, {'ensure' => 'installed' })
  ensure_resource('package', $git::params::python_json, {'ensure' => 'installed' })

  vcsrepo {
    '/git/grokmirror':
      ensure   => 'latest',
      provider => 'git',
      source   => 'git://github.com/mricon/grokmirror.git',
      user     => 'git',
      revision => 'wr';
  }
}
