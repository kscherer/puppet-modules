class vswitch::ovs(
  $package_ensure = 'present'
) {
  case $::osfamily {
    Debian: {
      package {["openvswitch-common",
                "openvswitch-switch"]:
        ensure  => $package_ensure,
        before  => Service['openvswitch-switch'],
      }
    }
  }

  service {"openvswitch-switch":
    ensure      => true,
    enable      => true,
    hasstatus   => true,
    status      => "/etc/init.d/openvswitch-switch status",
  }
}
