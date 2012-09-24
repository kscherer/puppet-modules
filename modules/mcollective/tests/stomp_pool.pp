node default {

  $stomp_server1 = { host => 'stomp1', port => '61612', user => 'mcollective',
    password => 'marionette'}
  $stomp_server2 = { host => 'stomp2', port => '6163', user => 'mcollective',
    password => 'marionette', ssl => true }
  $stomp_pool = { 1 => $stomp_server1, 2 => $stomp_server2 }

  class {
    'mcollective':
      pool          => $stomp_pool,
      plugin_params => { 'puppetd.puppetd' => '/usr/bin/puppet agent' }
  }
}
