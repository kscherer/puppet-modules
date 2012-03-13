# source.pp
# add an apt source

define apt::source(
  $location = '',
  $release = 'karmic',
  $repos = 'main',
  $include_src = true,
  $required_packages = false,
  $key = false,
  $key_server = 'keyserver.ubuntu.com',
  $pin = false,
  $ensure = 'file',
  $key_content = false
) {

  include apt::params

  file { "${name}.list":
    ensure  => $ensure,
    name    => "${apt::params::root}/sources.list.d/${name}.list",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('apt/source.list.erb'),
  }

  exec { "${name} apt update":
    command     => "${apt::params::provider} update",
    subscribe   => File["${name}.list"],
    refreshonly => true,
  }

  if $ensure != 'absent' {

    if $pin != false {
      apt::pin { $release: priority => $pin }
    }

    if $required_packages != false {
      exec { "${apt::params::provider} -y install ${required_packages}":
        subscribe   => File["${name}.list"],
        refreshonly => true,
      }
    }

    if $key != false {
      if $key_content {
        exec { "Add key: ${key} from content":
          command => "/bin/echo '${key_content}' | /usr/bin/apt-key add -",
          unless  => "/usr/bin/apt-key list | /bin/grep '${key}'",
          before  => File["${name}.list"],
        }
      } else {
        exec { "/usr/bin/apt-key adv --keyserver ${key_server} --recv-keys ${key}":
          unless => "/usr/bin/apt-key list | /bin/grep ${key}",
          before => File["${name}.list"],
        }
      }
    }
  }
}
