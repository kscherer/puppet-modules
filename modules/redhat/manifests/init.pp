# Class to setup all redhat type systems
class redhat {

  anchor { 'redhat::begin': }
  -> class { 'redhat::repos': }
  -> class { 'redhat::workarounds': }
  -> anchor { 'redhat::end': }

}
