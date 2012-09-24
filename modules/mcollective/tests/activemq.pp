node default {

  $activemq_server1 = { host => 'activemq1', port => '61612', user => 'mcollective',
    password => 'marionette'}
  $activemq_server2 = { host => 'activemq2', port => '6163', user => 'mcollective',
    password => 'marionette', ssl => true }
  $activemq_pool = { 1 => $activemq_server1, 2 => $activemq_server2 }

  class {
    'mcollective':
      connector => 'activemq',
      pool      => $activemq_pool;
  }
}
