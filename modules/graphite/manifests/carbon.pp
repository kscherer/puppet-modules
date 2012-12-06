# = Class: graphite::carbon
#
# Install carbon and enable carbon.
#
# == Actions:
#
# Installs the carbon package and enables the carbon service.
#
# == Todo:
#
# * Update documentation
#
class graphite::carbon {

  include graphite::carbon::package
  include graphite::carbon::config
  include graphite::carbon::service

  anchor { 'graphite::carbon::begin': }
  -> Class['graphite::carbon::package']
  -> Class['graphite::carbon::config']
  -> Class['graphite::carbon::service']
  -> anchor { 'graphite::carbon::end': }
}

