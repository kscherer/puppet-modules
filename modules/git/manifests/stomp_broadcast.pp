# Installs the git hook which will broadcast pushes using stomp
class git::stomp_broadcast {
  include git::stomp_repo

}
