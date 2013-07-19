class graphite::whisper::package {
  package {'whisper':
    ensure => present,
    name   => 'python-whisper';
  }
}
