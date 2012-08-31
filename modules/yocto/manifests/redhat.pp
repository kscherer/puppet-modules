class yocto::redhat {
  #buildbot needs some packages not part of wrlinux required files
  #glibc_std in yocto requires OpenGL
  package {
    [ 'texi2html', 'chrpath','diffstat','subversion','mesa-libGL', 'mesa-libGLU',
      'SDL-devel', 'texinfo', 'gawk', 'gcc', 'gcc-c++', 'help2man']:
        ensure => installed;
  }

  if $::architecture == 'x86_64' {
    #on RedHat/CentOS 5 the package is i386
    case $::operatingsystemrelease {
      /^5.*/:   { $arch = 'i386' }
      default: { $arch = 'i686' }
    }
    package {
      ['glibc.i686',"glibc-devel.$arch","libgcc.$arch"]:
        ensure => installed;
    }
  }
}
