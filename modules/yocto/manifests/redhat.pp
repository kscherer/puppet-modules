class yocto::redhat {
  #buildbot needs some packages not part of wrlinux required files
  #glibc_std in yocto requires OpenGL
  package {
    [ 'texi2html', 'chrpath','diffstat','subversion','mesa-libGL', 'mesa-libGLU',
      'SDL-devel', 'texinfo', 'gawk', 'gcc', 'gcc-c++', 'help2man']:
        ensure => installed;
  }

  package {
    'expat-devel':
      ensure => absent;
  }

  if $::architecture == 'x86_64' {
    package {
      'glibc.i686':
        ensure => installed;
    }
  }
}
