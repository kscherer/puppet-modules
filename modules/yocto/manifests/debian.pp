class yocto::debian {
  #buildbot needs some packages not part of wrlinux required files
  #glibc_std in yocto requires OpenGL
  package {
    [ 'texi2html', 'chrpath','diffstat','subversion','libgl1-mesa-dev', 'libglu1-mesa-dev',
      'libsdl1.2-dev', 'texinfo', 'gawk']:
        ensure => installed;
  }

}
