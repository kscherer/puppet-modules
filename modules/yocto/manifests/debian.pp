class yocto::debian {
  #buildbot needs some packages not part of wrlinux required files
  #glibc_std in yocto requires OpenGL
  package {
    [ 'texi2html', 'chrpath','diffstat','subversion','libgl1-mesa-dev',
      'libglu1-mesa-dev', 'libsdl1.2-dev', 'texinfo', 'gawk', 'gcc',
      'help2man', 'libexpat1-dev']:
        ensure => installed;
  }

  if $::architecture =~ /(x86_64|amd64)/ {
    if $::operatingsystemrelease == '10.04' {
      package {
        'libc6-i386':
          ensure => installed;
      }
    } else {
      package {
        'libc6:i386':
          ensure => installed;
      }
    }
  }
}
