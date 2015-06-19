# The name is a hash which is really wierd.
# TODO: rewrite using future parser
define wr::extract_key($user) {
  if $name {
    $key=split($name,' ')
    ssh_authorized_key {
      $key[2]:
        ensure => present,
        type   => $key[0],
        key    => $key[1],
        user   => $user;
    }
  }
}
