#Setup grok mirror on the master
class git::grokmirror::master {

  include git::grokmirror::base

  #use apache to serve git repo manifest
  include apache

}
