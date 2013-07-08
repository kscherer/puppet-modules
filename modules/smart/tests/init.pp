class {'smart':
  devices    => ['/dev/sda', '/dev/sdb',],
  email      => 'mail@example.org',
  email_type => 'diminishing',
  sheldule   => '(S/../../(1|2|4|5|6)/01|L/../../(3|7)/01)',
}