define vswitch::port (
  $interface = $name,
  $bridge,
  $ensure = present
) {
  vs_port { $interface:
    bridge   => $bridge,
    ensure   => $ensure
  }
}
