#
class wr::yow_ovp_rhel {
  include nis
  include apache
  include ntp
  include sudo
 
   sudo::conf {
     'test':
       source  => 'puppet:///modules/wr/sudoers.d/test';
 	'ityow':
 	 source  => 'puppet:///modules/wr/sudoers.d/ityow';
     'ovp':
 	source   => 'puppet:///modules/wr/sudoers.d/ovp';
   }
  
  file {
	'/etc/samba/smb.conf':
	ensure => present,
	content => template('wr/samba.conf.erb');
 }
  
  file {
 	'/etc/exports':
 	ensure => present,
 	content => '/buildarea1   *(rw,insecure,async,insecure_locks) 
	/buildarea2   *(rw,insecure,async,insecure_locks) 
	/buildarea3   *(rw,insecure,async,insecure_locks) 
	/buildarea4   *(rw,insecure,async,insecure_locks)';
   }
   
      package {
     [ '6-2','abrt','abrt-addon-ccpp', 'abrt-addon-kerneloops', 'abrt-addon-python', 'abrt-cli', 
	   'abrt-libs', 'abrt-tui', 'acl', 'acpid', 'aic94xx-firmware', 'alsa-lib', 'alsa-lib-devel', 'alsa-plugins-pulseaudio',
       'alsa-utils', 'apr', 'apr-util', 'at', 'atk', 'atmel-firmware', 'at-spi', 'at-spi-python', 'attr', 'audit',
       'audit-libs', 'augeas-libs', 'authconfig', 'authconfig-gtk', 'autoconf', 'automake', 'avahi-autoipd',
       'avahi-glib', 'avahi-libs', 'b43-fwcutter', 'b43-openfwwf', 'basesystem', 'bc', 'bfa-firmware', 'bind-libs',
       'bind-utils', 'binutils', 'biosdevname', 'bison', 'blktrace', 'bridge-utils', 'btparser', 'busybox', 'byacc', 'bzip2',
       'bzip2-libs', 'ca-certificates', 'cairo', 'cdparanoia-libs', 'checkpolicy', 'chkconfig', 'chrpath', 'cloog-ppl', 
       'compat-readline5', 'comps-extras', 'ConsoleKit', 'ConsoleKit-libs', 'ConsoleKit-x11', 'control-center',
       'control-center-extra', 'control-center-filesystem', 'coreutils', 'coreutils-libs', 'cpio', 'cpp', 'cpuspeed', 'cracklib',
       'cracklib-dicts', 'cracklib-python', 'crda', 'cronie', 'cronie-anacron', 'crontabs', 'cryptsetup-luks',
       'cryptsetup-luks-libs', 'cscope', 'ctags', 'cups', 'cups-libs', 'curl', 'cvs', 'cyrus-sasl',
       'cyrus-sasl-lib', 'cyrus-sasl-plain', 'dash', 'db4', 'db4-cxx', 'db4-devel', 'db4-utils', 'dbus', 'dbus-glib', 'dbus-libs',
       'dbus-python', 'dbus-x11', 'desktop-file-utils', 'DeviceKit-power', 'device-mapper', 'device-mapper-event',
       'device-mapper-event-libs', 'device-mapper-libs', 'device-mapper-persistent-data', 'dhclient', 'dhcp-common', 'diffstat', 'diffutils',
       'dmidecode', 'dmraid', 'dmraid-events', 'dmz-cursor-themes', 'dnsmasq', 'docbook-dtds', 'dosfstools', 'doxygen', 'dracut', 'dracut-kernel',
       'e2fsprogs', 'e2fsprogs-libs', 'ed', 'efibootmgr', 'eggdbus', 'eject', 'elfutils',
       'elfutils-libelf', 'elfutils-libs', 'enchant', 'eog', 'epel-release', 'ethtool', 'evolution-data-server', 'exempi', 'expat', 'facter',
       'festival', 'festival-lib', 'festival-speechtools-libs', 'festvox-slt-arctic-hts', 'file', 'file-libs', 'filesystem', 'findutils', 
       'fipscheck', 'fipscheck-lib', 'firstboot', 'flac', 'flex', 'fontconfig', 'fontpackages-filesystem', 'foomatic', 'foomatic-db',
       'foomatic-db-filesystem', 'foomatic-db-ppds', 'fprintd', 'fprintd-pam', 'freetype', 'fuse', 'fuse-libs', 'gamin', 'gawk',
       'gcc', 'gcc-c++', 'gcc-gfortran', 'GConf2', 'GConf2-gtk', 'gdb', 'gdbm', 'gdbm-devel', 'gdk-pixbuf2', 'gdm', 'gdm-libs', 
       'gdm-plugin-fingerprint', 'gdm-user-switch-applet', 'gedit', 'gettext', 'gettext-devel', 'gettext-libs', 'ghostscript', 
       'ghostscript-fonts', 'giflib', 'git', 'glib2', 'glibc', 'glibc-common', 'glibc-devel', 'glibc-headers', 'glib-networking',
       'glx-utils', 'gmp', 'gnome-applets', 'gnome-bluetooth-libs', 'gnome-desktop', 'gnome-disk-utility-libs', 'gnome-doc-utils-stylesheets',
       'gnome-icon-theme', 'gnome-keyring', 'gnome-keyring-pam', 'gnome-mag', 'gnome-media', 'gnome-media-libs', 'gnome-menus',
       'gnome-packagekit', 'gnome-panel', 'gnome-panel-libs', 'gnome-power-manager', 'gnome-python2', 'gnome-python2-applet', 'gnome-python2-bonobo',
       'gnome-python2-canvas', 'gnome-python2-desktop', 'gnome-python2-extras', 'gnome-python2-gconf', 'gnome-python2-gnome', 'gnome-python2-gnomevfs',
       'gnome-python2-libegg', 'gnome-python2-libwnck', 'gnome-screensaver', 'gnome-session', 'gnome-session-xsession', 'gnome-settings-daemon',
       'gnome-speech', 'gnome-terminal', 'gnome-themes', 'gnome-user-docs', 'gnome-vfs2',
       'gnome-vfs2-smb', 'gnupg2', 'gnutls', 'gok', 'gpgme', 'gpm-libs', 'grep', 'groff', 'grub', 'grubby',
       'gstreamer', 'gstreamer-plugins-base', 'gstreamer-plugins-good', 'gstreamer-tools', 'gtk2', 'gtk2-engines', 'gtksourceview2', 'gucharmap',
       'gvfs', 'gvfs-archive', 'gvfs-fuse', 'gvfs-smb', 'gzip', 'hal', 'hal-info', 'hal-libs', 'hdparm', 'help2man', 'hesiod',
       'hicolor-icon-theme', 'hiera', 'htop', 'hunspell', 'hunspell-en', 'hwdata', 'indent', 'info', 'initscripts', 'Installed Packages',
       'intltool', 'iproute', 'iptables', 'iptables-ipv6', 'iputils', 'ipw2100-firmware', 'ipw2200-firmware', 'irqbalance', 'iso-codes', 'ivtv-firmware',
       'iw', 'iwl1000-firmware', 'iwl100-firmware', 'iwl3945-firmware', 'iwl4965-firmware', 'iwl5000-firmware', 'iwl5150-firmware', 'iwl6000-firmware',
       'iwl6000g2a-firmware', 'iwl6050-firmware', 'jasper-libs', 'java-1', 'jpackage-utils', 'kbd', 'kbd-misc', 'kernel', 'kernel-devel', 'kernel-firmware', 'kernel-headers',
       'kexec-tools', 'keyutils', 'keyutils-libs', 'kpartx', 'kpathsea', 'krb5-libs', 'latex2html', 'lcms-libs',
       'ledmon', 'less', 'libacl', 'libaio', 'libarchive', 'libart_lgpl', 'libasyncns', 'libatasmart', 'libattr', 'libavc1394',
       'libblkid', 'libbonobo', 'libbonoboui', 'libcanberra', 'libcanberra-gtk2', 'libcap', 'libcap-ng', 'libcdio', 'libcom_err', 'libcroco',
       'libcurl', 'libdaemon', 'libdmx', 'libdrm', 'libdrm-devel', 'libdv', 'libedit', 'liberation-fonts-common',
       'liberation-sans-fonts', 'libertas-usb8388-firmware', 'libevent', 'libexif', 'libffi', 'libfontenc', 'libfprint', 'libgail-gnome', 'libgcc',
       'libgcj', 'libgcrypt', 'libgdata', 'libgfortran', 'libglade2', 'libgnome', 'libgnomecanvas', 'libgnomekbd', 'libgnomeui', 'libgomp',
       'libgpg-error', 'libgsf', 'libgssglue', 'libgtop2', 'libgudev1', 'libgweather', 'libical', 'libICE', 'libIDL', 'libidn',
       'libiec61883', 'libjpeg-turbo', 'libmcpp', 'libmcrypt', 'libmng', 'libnih', 'libnl', 'libnotify', 'libogg', 'liboil', 'libpcap', 'libpciaccess',
       'libpng', 'libproxy', 'libproxy-bin', 'libproxy-python', 'libraw1394', 'libreport', 'libreport-cli', 'libreport-compat', 'libreport-gtk', 'libreport-newt',
       'libreport-plugin-kerneloops', 'libreport-plugin-logger', 'libreport-plugin-mailx', 'libreport-plugin-reportuploader',
       'libreport-plugin-rhtsupport', 'libreport-python', 'librsvg2', 'libsamplerate',
       'libselinux', 'libselinux-python', 'libselinux-ruby', 'libselinux-utils', 'libsemanage', 'libsepol', 'libshout', 'libSM',
       'libsmbclient', 'libsndfile', 'libsoup', 'libss', 'libssh2', 'libstdc++', 'libstdc++-devel', 'libtalloc', 'libtar', 'libtasn1', 'libtdb',
       'libtevent', 'libthai', 'libtheora', 'libtiff', 'libtirpc', 'libtool', 'libtool-ltdl', 'libudev', 'libusb', 'libusb1', 'libuser',
       'libuser-python', 'libutempter', 'libuuid', 'libv4l', 'libvisual', 'libvorbis', 'libwacom', 'libwacom-data', 'libwnck', 'libX11',
       'libX11-common', 'libX11-devel', 'libXau', 'libXau-devel', 'libxcb', 'libxcb-devel', 'libXcomposite', 'libXcursor', 'libXdamage',
       'libXdamage-devel', 'libXdmcp', 'libXext', 'libXext-devel', 'libXfixes', 'libXfixes-devel', 'libXfont', 'libXft', 'libXi', 'libXinerama',
       'libxkbfile', 'libxklavier', 'libxml2', 'libxml2-python', 'libXmu', 'libXrandr', 'libXrandr-devel', 'libXrender', 'libXrender-devel',
       'libXres', 'libXScrnSaver', 'libxslt', 'libXt', 'libXtst', 'libXv', 'libXvMC', 'libXxf86dga', 'libXxf86misc', 'libXxf86vm', 'libXxf86vm-devel',
       'logrotate', 'lsof', 'lua', 'lvm2', 'lvm2-libs', 'lzo', 'm2crypto', 'm4','mailx', 'make', 'MAKEDEV', 'man', 'man-pages', 
       'man-pages-overrides', 'mcollective', 'mcollective-common', 'mcpp', 'mdadm', 'mesa-dri1-drivers', 'mesa-dri-drivers', 'mesa-dri-filesystem',
       'mesa-libEGL', 'mesa-libgbm', 'mesa-libGL', 'mesa-libGL-devel', 'mesa-libGLU', 'mesa-libGLU-devel', 'mesa-private-llvm', 'metacity',
       'microcode_ctl', 'mingetty', 'mlocate', 'mobile-broadband-provider-info', 'ModemManager', 'module-init-tools', 'mosh', 'mozilla-filesystem',
       'mpfr', 'mtdev', 'mtools', 'mtr', 'mysql-libs', 'nagios-common', 'nagios-plugins', 'nagios-plugins-disk', 'nagios-plugins-file_age',
       'nagios-plugins-ntp', 'nagios-plugins-openmanage', 'nagios-plugins-perl', 'nagios-plugins-procs', 'nano', 'nautilus', 'nautilus-extensions',
       'ncurses', 'ncurses-base', 'ncurses-libs', 'neon', 'netpbm', 'netpbm-progs', 'net-tools', 'NetworkManager', 'NetworkManager-glib',
       'NetworkManager-gnome', 'newt', 'newt-python', 'notification-daemon', 'nsca-client', 'nspr', 'nss',
       'nss-softokn', 'nss-softokn-freebl', 'nss-sysinit', 'nss-tools', 'nss-util', 'ntpdate', 'ntsysv', 'numactl', 'openjpeg-libs',
       'openldap', 'openssh', 'openssh-askpass', 'openssh-clients', 'openssh-server', 'openssl', 'ORBit2', 'orca', 'p11-kit', 'p11-kit-trust',
       'PackageKit', 'PackageKit-device-rebind', 'PackageKit-glib', 'PackageKit-gtk-module', 'PackageKit-yum', 'PackageKit-yum-plugin',
       'pakchois', 'pam', 'pam_passwdqc', 'pango', 'parted', 'passwd', 'patch', 'patchutils', 'pax', 'pciutils', 'pciutils-libs', 'pcmciautils',
       'pcre', 'perl', 'perl-CGI', 'perl-Compress-Raw-Zlib', 'perl-Compress-Zlib', 'perl-Config-Tiny', 'perl-Crypt-DES', 'perl-devel',
       'perl-Digest-HMAC', 'perl-Digest-SHA1', 'perl-Error', 'perl-ExtUtils-MakeMaker', 'perl-ExtUtils-ParseXS', 'perl-Git', 'perl-HTML-Parser',
       'perl-HTML-Tagset', 'perl-IO-Compress-Base', 'perl-IO-Compress-Zlib', 'perl-libs', 'perl-libwww-perl', 'perl-Module-Pluggable',
       'perl-Net-SNMP', 'perl-Pod-Escapes', 'perl-Pod-Simple', 'perl-Test-Harness', 'perl-Test-Simple', 'perl-Text-Unidecode', 'perl-URI',
       'perl-version', 'perl-XML-Parser', 'phonon-backend-gstreamer', 'pinentry', 'pinfo', 'pixman', 'pkgconfig', 'plymouth', 'plymouth-core-libs',
       'plymouth-gdm-hooks', 'plymouth-graphics-libs', 'plymouth-plugin-label', 'plymouth-plugin-two-step', 'plymouth-scripts',
       'plymouth-system-theme', 'plymouth-theme-rings', 'plymouth-utils', 'pm-utils', 'policycoreutils', 'polkit', 'polkit-desktop-policy',
       'polkit-gnome', 'poppler', 'poppler-data', 'poppler-utils', 'popt', 'portreserve', 'postfix', 'ppl', 'ppp', 'prelink', 'procps',
       'protobuf', 'psacct', 'psmisc', 'psutils', 'pth', 'pulseaudio', 'pulseaudio-gdm-hooks', 'pulseaudio-libs', 'pulseaudio-libs-glib2',
       'pulseaudio-module-gconf', 'pulseaudio-module-x11', 'pulseaudio-utils', 'puppet', 'puppetlabs-release', 'pycairo', 'pygobject2',
       'pygpgme', 'pygtk2', 'pygtk2-libglade', 'pygtksourceview', 'pyOpenSSL', 'pyorbit', 'python', 'python-dateutil', 'python-dmidecode',
       'python-ethtool', 'python-gudev', 'python-iniparse', 'python-iwlib', 'python-libs', 'python-lxml', 'python-meh', 'python-pycurl',
       'python-rhsm', 'python-simplejson', 'python-slip', 'python-urlgrabber', 'pyxf86config', 'ql2100-firmware', 'ql2200-firmware',
       'ql23xx-firmware', 'ql2400-firmware', 'ql2500-firmware', 'qt', 'qt3', 'qt-sqlite', 'qt-x11', 'quota', 'rarian', 'rarian-compat',
       'rcs', 'rdate', 'readahead', 'readline', 'Red_Hat_Enterprise_Linux-Release_Notes-6-en-US', 'redhat-indexhtml', 'redhat-logos',
       'redhat-lsb', 'redhat-lsb-compat', 'redhat-lsb-core', 'redhat-lsb-graphics', 'redhat-lsb-printing', 'redhat-menus',
       'redhat-release-workstation', 'redhat-rpm-config', 'redhat-support-lib-python', 'redhat-support-tool', 'rfkill',
       'rhn-check', 'rhn-client-tools', 'rhnlib', 'rhnsd', 'rhn-setup', 'rhn-setup-gnome', 'rng-tools', 'rootfiles', 'rpm',
       'rpm-build', 'rpm-libs', 'rpm-python', 'rsync', 'rsyslog', 'rt61pci-firmware', 'rt73usb-firmware', 'rtkit', 'ruby', 'ruby-augeas',
       'rubygem-json', 'rubygems', 'rubygem-stomp', 'ruby-irb', 'ruby-libs', 'ruby-rdoc', 'ruby-shadow', 'samba-common', 'samba-winbind',
       'samba-winbind-clients', 'scl-utils', 'screen', 'SDL', 'SDL-devel', 'sed', 'selinux-policy', 'selinux-policy-targeted', 'setserial',
       'setup', 'setuptool', 'sg3_utils-libs', 'sgml-common', 'sgpio', 'shadow-utils', 'shared-mime-info', 'slang', 'smartmontools',
       'smp_utils', 'snappy', 'sos', 'sound-theme-freedesktop', 'speex', 'spice-vdagent', 'sqlite', 'startup-notification', 'strace',
       'subscription-manager', 'subscription-manager-firstboot', 'subscription-manager-gui', 'subversion', 'swig', 'sysstat',
       'system-config-date', 'system-config-date-docs', 'system-config-firewall-base', 'system-config-firewall-tui', 'system-config-keyboard',
       'system-config-keyboard-base', 'system-config-network-tui', 'system-config-users', 'system-config-users-docs', 'system-gnome-theme',
       'system-icon-theme', 'system-setup-keyboard', 'systemtap', 'systemtap-client', 'systemtap-devel', 'systemtap-runtime', 'sysvinit-tools',
       'taglib', 'tar', 'tcpdump', 'tcp_wrappers', 'tcp_wrappers-libs', 'tcsh', 'texi2html', 'texinfo', 'texlive', 'texlive-dvips',
       'texlive-latex', 'texlive-texmf', 'texlive-texmf-dvips', 'texlive-texmf-errata', 'texlive-texmf-errata-dvips',
       'texlive-texmf-errata-fonts', 'texlive-texmf-errata-latex', 'texlive-texmf-fonts', 'texlive-texmf-latex', 'texlive-utils',
       'tex-preview', 'This system is not registered to Red Hat Subscription Management', 'tigervnc', 'tigervnc-server', 'time',
       'tmpwatch', 'traceroute', 'ttmkfdir', 'tzdata', 'tzdata-java', 'udev', 'udisks', 'unique', 'unzip', 'upstart', 'urw-fonts',
       'usbutils', 'usermode', 'usermode-gtk', 'ustr', 'util-linux-ng', 'vconfig', 'vim-common', 'vim-enhanced', 'vim-minimal', 'vino',
       'virt-what', 'vte', 'wacomexpresskeys', 'wavpack', 'wdaemon', 'wget', 'which', 'wireless-tools', 'words', 'wpa_supplicant',
       'xcb-util', 'xdg-user-dirs', 'xdg-user-dirs-gtk', 'xdg-utils', 'xkeyboard-config', 'xml-common', 'xmlrpc-c', 'xmlrpc-c-client',
       'xorg-x11-drivers', 'xorg-x11-drv-acecad', 'xorg-x11-drv-aiptek', 'xorg-x11-drv-apm', 'xorg-x11-drv-ast', 'xorg-x11-drv-ati',
       'xorg-x11-drv-ati-firmware', 'xorg-x11-drv-cirrus', 'xorg-x11-drv-dummy', 'xorg-x11-drv-elographics', 'xorg-x11-drv-evdev',
       'xorg-x11-drv-fbdev', 'xorg-x11-drv-fpit', 'xorg-x11-drv-glint', 'xorg-x11-drv-hyperpen', 'xorg-x11-drv-i128', 'xorg-x11-drv-i740',
       'xorg-x11-drv-intel', 'xorg-x11-drv-keyboard', 'xorg-x11-drv-mach64', 'xorg-x11-drv-mga', 'xorg-x11-drv-modesetting',
       'xorg-x11-drv-mouse', 'xorg-x11-drv-mutouch', 'xorg-x11-drv-nouveau', 'xorg-x11-drv-nv', 'xorg-x11-drv-openchrome',
       'xorg-x11-drv-penmount', 'xorg-x11-drv-qxl', 'xorg-x11-drv-r128', 'xorg-x11-drv-rendition', 'xorg-x11-drv-s3virge', 'xorg-x11-drv-savage',
       'xorg-x11-drv-siliconmotion', 'xorg-x11-drv-sis', 'xorg-x11-drv-sisusb', 'xorg-x11-drv-synaptics', 'xorg-x11-drv-tdfx',
       'xorg-x11-drv-trident', 'xorg-x11-drv-v4l', 'xorg-x11-drv-vesa', 'xorg-x11-drv-vmmouse', 'xorg-x11-drv-vmware', 'xorg-x11-drv-void',
       'xorg-x11-drv-voodoo', 'xorg-x11-drv-wacom', 'xorg-x11-drv-xgi', 'xorg-x11-fonts-misc', 'xorg-x11-fonts-Type1', 'xorg-x11-font-utils',
       'xorg-x11-glamor', 'xorg-x11-proto-devel', 'xorg-x11-server-common', 'xorg-x11-server-utils', 'xorg-x11-server-Xorg', 'xorg-x11-utils',
       'xorg-x11-xauth', 'xorg-x11-xinit', 'xorg-x11-xkb-utils', 'xulrunner', 'xvattr', 'xz', 'xz-libs', 'xz-lzma-compat', 'yelp',
       'yum', 'yum-metadata-parser', 'yum-plugin-security', 'yum-rhn-plugin',
       'yum-utils', 'zd1211-firmware', 'zenity', 'zip', 'zlib']:
       ensure => 'installed';
    }

}