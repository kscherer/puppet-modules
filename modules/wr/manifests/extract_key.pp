# The name is a string containing the type, key and id
define wr::extract_key($user) {
  if $name {
    $key=split($name,' ')
    $key_name=chomp($key[2])
    ssh_authorized_key {
      $key_name:
        ensure => present,
        type   => $key[0],
        key    => $key[1],
        user   => $user;
    }
  }
}
