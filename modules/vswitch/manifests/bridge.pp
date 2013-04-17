define vswitch::bridge (
  $external_ids = "",
  $ensure = "present"
) {
  vs_bridge { $name:
    external_ids => $external_ids,
    ensure       => $ensure
  }
}
