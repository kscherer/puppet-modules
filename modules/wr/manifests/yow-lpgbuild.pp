#
class wr::yow-lpgbuild {

  include profile::nxbuilder

  user {
    'root':
      password => '$6$p6ikdyj/GHN7Uno3$VDlbq91Mp5osT0yLxVTbtDhhidFYTK7r/2xM5426g6bbesNzfhaXditRBSieRwsgpNJIbYEQhA7SZcXdf.VcZ0';
  }
}
