#
class profile::docker::dnsmasq {
  # Use dnsmasq to expose consul dns to host and container DNS lookups
  include ::dnsmasq

  # Any lookups to .consul domain are redirected to consul DNS port
  ::dnsmasq::conf {
    'consul':
      ensure  => present,
      content => 'server=/consul/127.0.0.1#8600',
  }

  # Expose dnsmasq on port 53 only to localhost and on docker bridge
  # This requires that docker daemon is configured with dns as bridge interface ip
  ::dnsmasq::conf {
    'docker':
      ensure  => present,
      content => "interface=lo\ninterface=docker0\nbind-interfaces",
  }
}
