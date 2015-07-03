# Install x2go server packages
class x2go::package {
  if $::operatingsystem == 'Ubuntu' {
    # setup x2go server to provide remote graphical access
    apt::ppa { 'ppa:x2go/stable': }
    package {
      ['x2goserver', 'x2goserver-extensions', 'x2goserver-xsession', 'xterm']:
        ensure => latest,
        require => Apt::Ppa['ppa:x2go/stable'];
    }
  }
}
