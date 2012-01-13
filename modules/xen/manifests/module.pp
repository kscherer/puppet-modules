#load and autoload modules
define xen::module(){
  exec {
    "load_${name}":
      command => "modprobe $name",
      path    => '/sbin:/bin:/usr/bin',
      unless  => "lsmod | grep -q $name";
  }

  line {
    "load_${name}_on_boot":
      file => '/etc/modules',
      line => $name;
  }
}
