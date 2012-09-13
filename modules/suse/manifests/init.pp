#
class suse {
  ensure_resource( 'package', 'lsb-release', {'ensure' => 'installed' })
}
