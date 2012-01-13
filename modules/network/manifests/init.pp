
#this class provides infrastructure for custom puppet network class
class network {

  #simple way to restart network after making config changes
  case $operatingsystem {
    RedHat,Fedora,CentOS : {
      service {
        'network':
          ensure     => running,
          enable     => true,
          hasstatus  => true,
          hasrestart => true;
      }
    }
  }
}
