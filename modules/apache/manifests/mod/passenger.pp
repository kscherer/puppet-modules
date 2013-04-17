class apache::mod::passenger {
  include 'apache'

  apache::mod { 'passenger': }

  #Make sure conf file installed by passenger package does not get clobbered
  file { "${apache::params::vdir}/passenger.conf":
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root;
  }
}
