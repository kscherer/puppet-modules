class yocto::suse {
  #buildbot needs some packages not part of wrlinux required files
  #glibc_std in yocto requires OpenGL
  package {
    [ 'chrpath','diffstat','subversion','Mesa', 'Mesa-devel',
      'libSDL-devel', 'texinfo', 'gawk', 'gcc', 'gcc-c++', 'help2man']:
        ensure => installed;
  }
}
