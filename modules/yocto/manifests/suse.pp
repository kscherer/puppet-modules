class yocto::suse {
  if $::operatingsystem == 'OpenSuSE' and $::operatingsystemrelease == '12.1' {
    #buildbot needs some packages not part of wrlinux required files
    #glibc_std in yocto requires OpenGL
    package {
      [ 'chrpath','diffstat','subversion','Mesa', 'Mesa-devel', 'make',
        'libSDL-devel', 'texinfo', 'gawk', 'gcc', 'gcc-c++', 'help2man',
        'patch', 'python-curses','libsqlite3-0']:
          ensure => installed;
    }

  } elsif $::operatingsystem == 'SLED' {
    package {
      [ 'make', 'texinfo', 'gawk', 'gcc', 'gcc-c++', 'patch', 'diffstat',
        'subversion', 'chrpath', 'Mesa-devel', 'SDL-devel', 'python-curses']:
          ensure => installed;
    }
  }

  if $::architecture == 'x86_64' {
    package {
      'glibc-devel-32bit':
        ensure => installed;
    }
  }
}
