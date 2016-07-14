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
}
