# The name is a hash which is really wierd.
# TODO: rewrite using future parser
define wr::extract_key($user) {
  $key=split($name["sshpubkey_wrlbuild"],' ')
  ssh_authorized_key {
    $key[2]:
      ensure => present,
      type   => $key[0],
      key    => $key[1],
      user   => $user;
  }
}
