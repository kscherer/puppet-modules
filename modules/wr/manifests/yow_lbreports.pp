#
class wr::yow_lbreports {
  include nis
  include apache
  include ntp
  include sudo

  sudo::conf {
    'test':
      source => 'puppet:///modules/wr/sudoers.d/test';

    'ityow':
      source => 'puppet:///modules/wr/sudoers.d/ityow';

    'ovp':
      source => 'puppet:///modules/wr/sudoers.d/ovp';
  }

  file { '/etc/samba/smb.conf':
    ensure  => present,
    content => template('wr/samba.conf.erb');
  }

  package { [
    "abattis-cantarell-fonts",
    "abrt",
    "abrt-addon-ccpp",
    "abrt-addon-kerneloops",
    "abrt-addon-pstoreoops",
    "abrt-addon-python",
    "abrt-addon-vmcore",
    "abrt-addon-xorg",
    "abrt-cli",
    "abrt-console-notification",
    "abrt-dbus",
    "abrt-desktop",
    "abrt-gui",
    "abrt-gui-libs",
    "abrt-libs",
    "abrt-python",
    "abrt-tui",
    "accountsservice",
    "accountsservice-libs",
    "acl",
    "adcli",
    "adwaita-cursor-theme",
    "adwaita-gtk2-theme",
    "adwaita-gtk3-theme",
    "aic94xx-firmware",
    "alsa-firmware",
    "alsa-lib",
    "alsa-plugins-pulseaudio",
    "alsa-tools-firmware",
    "alsa-utils",
    "anaconda",
    "anaconda-widgets",
    "apr",
    "apr-util",
    "at",
    "atk",
    "atkmm",
    "at-spi2-atk",
    "at-spi2-core",
    "attr",
    "audit",
    "audit-libs",
    "audit-libs-python",
    "augeas-libs",
    "authconfig",
    "autocorr-en",
    "autogen-libopts",
    "avahi",
    "avahi-autoipd",
    "avahi-glib",
    "avahi-gobject",
    "avahi-libs",
    "avahi-ui-gtk3",
    "baobab",
    "basesystem",
    "bash-completion",
    "bc",
    "bind-libs",
    "bind-libs-lite",
    "bind-license",
    "bind-utils",
    "binutils",
    "biosdevname",
    "blktrace",
    "bluez",
    "bluez-libs",
    "boost-date-time",
    "boost-signals",
    "boost-system",
    "brasero",
    "brasero-libs",
    "brasero-nautilus",
    "bridge-utils",
    "brlapi",
    "brltty",
    "btrfs-progs",
    "bzip2",
    "bzip2-libs",
    "ca-certificates",
    "cairo",
    "cairo-gobject",
    "cairomm",
    "c-ares",
    "caribou",
    "caribou-gtk2-module",
    "caribou-gtk3-module",
    "cdparanoia",
    "cdparanoia-libs",
    "cdrdao",
    "celt051",
    "centos-bookmarks",
    "centos-indexhtml",
    "centos-logos",
    "centos-release",
    "certmonger",
    "cgdcbxd",
    "checkpolicy",
    "chkconfig",
    "chrony",
    "cifs-utils",
    "cjkuni-uming-fonts",
    "clucene-contribs-lib",
    "clucene-core",
    "clutter",
    "clutter-gst2",
    "clutter-gtk",
    "cogl",
    "colord",
    "colord-gtk",
    "colord-libs",
    "color-filesystem",
    "comps-extras",
    "control-center",
    "control-center-filesystem",
    "coreutils",
    "cpio",
    "cracklib",
    "cracklib-dicts",
    "crash",
    "crda",
    "createrepo",
    "cronie-anacron",
    "crontabs",
    "cryptsetup",
    "cryptsetup-libs",
    "cryptsetup-python",
    "cups",
    "cups-filesystem",
    "cups-filters",
    "cups-filters-libs",
    "cups-libs",
    "cups-pk-helper",
    "curl",
    "cyrus-sasl",
    "cyrus-sasl-gssapi",
    "cyrus-sasl-lib",
    "cyrus-sasl-md5",
    "cyrus-sasl-plain",
    "cyrus-sasl-scram",
    "dbus",
    "dbus-glib",
    "dbus-libs",
    "dbus-python",
    "dbus-x11",
    "dconf",
    "dejavu-fonts-common",
    "dejavu-sans-fonts",
    "dejavu-sans-mono-fonts",
    "dejavu-serif-fonts",
    "deltarpm",
    "desktop-file-utils",
    "device-mapper",
    "device-mapper-event",
    "device-mapper-event-libs",
    "device-mapper-libs",
    "device-mapper-multipath",
    "device-mapper-multipath-libs",
    "device-mapper-persistent-data",
    "dhclient",
    "dhcp-common",
    "dhcp-libs",
    "diffutils",
    "dmidecode",
    "dmraid",
    "dmraid-events",
    "dnsmasq",
    "dos2unix",
    "dosfstools",
    "dotconf",
    "dracut",
    "dracut-config-rescue",
    "dracut-network",
    "dvd+rw-tools",
    "dyninst",
    "e2fsprogs",
    "e2fsprogs-libs",
    "ebtables",
    "ed",
    "efibootmgr",
    "ekiga",
    "elfutils",
    "elfutils-libelf",
    "elfutils-libs",
    "emacs-filesystem",
    "empathy",
    "enchant",
    "enscript",
    "eog",
    "epel-release",
    "espeak",
    "ethtool",
    "evince",
    "evince-libs",
    "evince-nautilus",
    "evolution",
    "evolution-data-server",
    "evolution-ews",
    "evolution-help",
    "evolution-mapi",
    "exempi",
    "exiv2-libs",
    "expat",
    "farstream",
    "farstream02",
    "fcoe-utils",
    "festival",
    "festival-freebsoft-utils",
    "festival-lib",
    "festival-speechtools-libs",
    "festvox-slt-arctic-hts",
    "fftw-libs-double",
    "file",
    "file-libs",
    "file-roller",
    "file-roller-nautilus",
    "filesystem",
    "findutils",
    "fipscheck",
    "fipscheck-lib",
    "firefox",
    "firewall-config",
    "firewalld",
    "firstboot",
    "flac-libs",
    "flite",
    "folks",
    "fontconfig",
    "fontpackages-filesystem",
    "fprintd",
    "fprintd-pam",
    "freerdp",
    "freerdp-libs",
    "freerdp-plugins",
    "freetype",
    "frei0r-plugins",
    "fros",
    "fuse",
    "fuseiso",
    "fuse-libs",
    "fxload",
    "gavl",
    "gawk",
    "GConf2",
    "gcr",
    "gd",
    "gdb",
    "gdbm",
    "gdisk",
    "gdk-pixbuf2",
    "gdm",
    "gdm-libs",
    "gedit",
    "genisoimage",
    "geoclue",
    "gettext",
    "gettext-libs",
    "ghostscript",
    "ghostscript-cups",
    "ghostscript-fonts",
    "giflib",
    "gjs",
    "glade-libs",
    "glib2",
    "glibc",
    "glibc-common",
    "glibmm24",
    "glib-networking",
    "glusterfs",
    "glusterfs-api",
    "glusterfs-fuse",
    "glusterfs-libs",
    "glx-utils",
    "gmp",
    "gnome-abrt",
    "gnome-backgrounds",
    "gnome-bluetooth",
    "gnome-bluetooth-libs",
    "gnome-boxes",
    "gnome-calculator",
    "gnome-classic-session",
    "gnome-clocks",
    "gnome-color-manager",
    "gnome-contacts",
    "gnome-desktop3",
    "gnome-dictionary",
    "gnome-disk-utility",
    "gnome-documents",
    "gnome-font-viewer",
    "gnome-getting-started-docs",
    "gnome-icon-theme",
    "gnome-icon-theme-extras",
    "gnome-icon-theme-legacy",
    "gnome-icon-theme-symbolic",
    "gnome-initial-setup",
    "gnome-keyring",
    "gnome-keyring-pam",
    "gnome-menus",
    "gnome-online-accounts",
    "gnome-packagekit",
    "gnome-screenshot",
    "gnome-session",
    "gnome-session-xsession",
    "gnome-settings-daemon",
    "gnome-settings-daemon-updates",
    "gnome-shell",
    "gnome-shell-extension-alternate-tab",
    "gnome-shell-extension-apps-menu",
    "gnome-shell-extension-common",
    "gnome-shell-extension-launch-new-instance",
    "gnome-shell-extension-places-menu",
    "gnome-shell-extension-window-list",
    "gnome-system-log",
    "gnome-system-monitor",
    "gnome-terminal",
    "gnome-themes-standard",
    "gnome-tweak-tool",
    "gnome-user-docs",
    "gnome-video-effects",
    "gnome-weather",
    "gnu-free-fonts-common",
    "gnu-free-mono-fonts",
    "gnu-free-sans-fonts",
    "gnu-free-serif-fonts",
    "gnupg2",
    "gnutls",
    "gnutls-dane",
    "gnutls-utils",
    "gobject-introspection",
    "google-crosextra-caladea-fonts",
    "google-crosextra-carlito-fonts",
    "gpgme",
    "gpm-libs",
    "graphite2",
    "grep",
    "grilo",
    "grilo-plugins",
    "groff-base",
    "grub2",
    "grub2-efi",
    "grub2-tools",
    "grubby",
    "gsettings-desktop-schemas",
    "gsm",
    "gssdp",
    "gssproxy",
    "gstreamer",
    "gstreamer1",
    "gstreamer1-plugins-bad-free",
    "gstreamer1-plugins-base",
    "gstreamer1-plugins-good",
    "gstreamer-plugins-bad-free",
    "gstreamer-plugins-base",
    "gstreamer-plugins-good",
    "gstreamer-tools",
    "gtk2",
    "gtk2-immodule-xim",
    "gtk3",
    "gtk3-immodule-xim",
    "gtkhtml3",
    "gtkmm24",
    "gtkmm30",
    "gtksourceview3",
    "gtk-vnc2",
    "gucharmap",
    "gupnp",
    "gupnp-av",
    "gupnp-igd",
    "gutenprint",
    "gutenprint-cups",
    "gvfs",
    "gvfs-afc",
    "gvfs-afp",
    "gvfs-archive",
    "gvfs-fuse",
    "gvfs-goa",
    "gvfs-gphoto2",
    "gvfs-mtp",
    "gvnc",
    "gzip",
    "hardlink",
    "harfbuzz",
    "harfbuzz-icu",
    "hdparm",
    "hesiod",
    "hicolor-icon-theme",
    "highlight",
    "hostname",
    "hpijs",
    "hplip-common",
    "hplip-libs",
    "hunspell",
    "hunspell-en",
    "hunspell-en-GB",
    "hunspell-en-US",
    "hwdata",
    "hyperv-daemons",
    "hyperv-daemons-license",
    "hypervkvpd",
    "hypervvssd",
    "hyphen",
    "hyphen-en",
    "ibus",
    "ibus-chewing",
    "ibus-gtk2",
    "ibus-gtk3",
    "ibus-hangul",
    "ibus-kkc",
    "ibus-libpinyin",
    "ibus-libs",
    "ibus-m17n",
    "ibus-rawcode",
    "ibus-sayura",
    "ibus-setup",
    "ibus-table",
    "ibus-table-chinese",
    "icedax",
    "icedtea-web",
    "imsettings",
    "imsettings-gsettings",
    "imsettings-libs",
    "info",
    "initial-setup",
    "initscripts",
    "Installed Packages",
    "ipa-client",
    "ipa-python",
    "iproute",
    "iprutils",
    "iptables",
    "iptables-services",
    "iputils",
    "ipxe-roms-qemu",
    "irqbalance",
    "iscsi-initiator-utils",
    "iscsi-initiator-utils-iscsiuio",
    "iso-codes",
    "isomd5sum",
    "ivtv-firmware",
    "iw",
    "iwl1000-firmware",
    "iwl100-firmware",
    "iwl105-firmware",
    "iwl135-firmware",
    "iwl2000-firmware",
    "iwl2030-firmware",
    "iwl3160-firmware",
    "iwl3945-firmware",
    "iwl4965-firmware",
    "iwl5000-firmware",
    "iwl5150-firmware",
    "iwl6000-firmware",
    "iwl6000g2a-firmware",
    "iwl6000g2b-firmware",
    "iwl6050-firmware",
    "iwl7260-firmware",
    "jansson",
    "jasper-libs",
    "java-1",
    "javapackages-tools",
    "jbigkit-libs",
    "jline",
    "jomolhari-fonts",
    "js",
    "json-c",
    "json-glib",
    "kbd",
    "kbd-misc",
    "kernel",
    "kernel-tools",
    "kernel-tools-libs",
    "kexec-tools",
    "keybinder3",
    "keyutils",
    "keyutils-libs",
    "khmeros-base-fonts",
    "khmeros-fonts-common",
    "kmod",
    "kmod-libs",
    "kpartx",
    "kpatch",
    "krb5-libs",
    "krb5-workstation",
    "langtable",
    "langtable-data",
    "langtable-python",
    "lcms2",
    "ldns",
    "ledmon",
    "less",
    "libacl",
    "libaio",
    "libao",
    "libarchive",
    "libassuan",
    "libasyncns",
    "libatasmart",
    "libattr",
    "libavc1394",
    "libbasicobjects",
    "libblkid",
    "libbluray",
    "libburn",
    "libcacard",
    "libcanberra",
    "libcanberra-gtk2",
    "libcanberra-gtk3",
    "libcap",
    "libcap-ng",
    "libcdio",
    "libcdio-paranoia",
    "libcdr",
    "libcgroup",
    "libcgroup-tools",
    "libchamplain",
    "libchamplain-gtk",
    "libchewing",
    "libcmis",
    "libcollection",
    "libcom_err",
    "libconfig",
    "libcroco",
    "libcurl",
    "libcurl-devel",
    "libdaemon",
    "libdb",
    "libdb-utils",
    "libdhash",
    "libdmapsharing",
    "libdmx",
    "libdnet",
    "libdrm",
    "libdv",
    "libdvdnav",
    "libdvdread",
    "libdwarf",
    "libedit",
    "liberation-fonts-common",
    "liberation-mono-fonts",
    "liberation-sans-fonts",
    "liberation-serif-fonts",
    "libertas-sd8686-firmware",
    "libertas-sd8787-firmware",
    "libertas-usb8388-firmware",
    "libestr",
    "libevent",
    "libexif",
    "libexttextcat",
    "libffi",
    "libfontenc",
    "libfprint",
    "libgcc",
    "libgcrypt",
    "libgdata",
    "libgdither",
    "libgee",
    "libgee06",
    "libgexiv2",
    "libglade2",
    "libgnomekbd",
    "libgnome-keyring",
    "libgomp",
    "libgovirt",
    "libgpg-error",
    "libgphoto2",
    "libgpod",
    "libgsf",
    "libgtop2",
    "libgudev1",
    "libgusb",
    "libgweather",
    "libgxps",
    "libhangul",
    "libhbaapi",
    "libhbalinux",
    "libibverbs",
    "libical",
    "libICE",
    "libicu",
    "libidn",
    "libiec61883",
    "libieee1284",
    "libimobiledevice",
    "libini_config",
    "libipa_hbac",
    "libipa_hbac-python",
    "libiptcdata",
    "libiscsi",
    "libisofs",
    "libjpeg-turbo",
    "libkkc",
    "libkkc-common",
    "libkkc-data",
    "liblangtag",
    "libldb",
    "liblouis",
    "liblouis-python",
    "libmbim",
    "libmcrypt",
    "libmnl",
    "libmodman",
    "libmount",
    "libmpcdec",
    "libmspub",
    "libmtp",
    "libmusicbrainz5",
    "libmwaw",
    "libmx",
    "libndp",
    "libnetfilter_conntrack",
    "libnfnetlink",
    "libnfsidmap",
    "libnice",
    "libnl",
    "libnl3",
    "libnl3-cli",
    "libnm-gtk",
    "libnotify",
    "liboauth",
    "libodfgen",
    "libofa",
    "libogg",
    "liborcus",
    "libosinfo",
    "libpath_utils",
    "libpcap",
    "libpciaccess",
    "libpeas",
    "libpinyin",
    "libpinyin-data",
    "libpipeline",
    "libplist",
    "libpng",
    "libproxy",
    "libproxy-mozjs",
    "libpurple",
    "libpwquality",
    "libqmi",
    "libquvi",
    "libquvi-scripts",
    "LibRaw",
    "libraw1394",
    "librdmacm",
    "libref_array",
    "libreoffice-calc",
    "libreoffice-core",
    "libreoffice-draw",
    "libreoffice-emailmerge",
    "libreoffice-graphicfilter",
    "libreoffice-impress",
    "libreoffice-math",
    "libreoffice-opensymbol-fonts",
    "libreoffice-pdfimport",
    "libreoffice-pyuno",
    "libreoffice-ure",
    "libreoffice-writer",
    "libreport",
    "libreport-anaconda",
    "libreport-cli",
    "libreport-filesystem",
    "libreport-gtk",
    "libreport-plugin-bugzilla",
    "libreport-plugin-mailx",
    "libreport-plugin-reportuploader",
    "libreport-plugin-rhtsupport",
    "libreport-plugin-ureport",
    "libreport-python",
    "libreport-rhel",
    "libreport-rhel-anaconda-bugzilla",
    "libreport-web",
    "libreswan",
    "librsvg2",
    "libsamplerate",
    "libsane-hpaio",
    "libseccomp",
    "libsecret",
    "libselinux",
    "libselinux-python",
    "libselinux-utils",
    "libsemanage",
    "libsemanage-python",
    "libsepol",
    "libshout",
    "libsigc++20",
    "libSM",
    "libsndfile",
    "libsoup",
    "libspectre",
    "libss",
    "libssh2",
    "libsss_idmap",
    "libstdc++",
    "libstoragemgmt",
    "libstoragemgmt-python",
    "libsysfs",
    "libtalloc",
    "libtar",
    "libtasn1",
    "libtdb",
    "libteam",
    "libtevent",
    "libthai",
    "libtheora",
    "libtidy",
    "libtiff",
    "libtirpc",
    "libtool-ltdl",
    "libudisks2",
    "libunistring",
    "libusal",
    "libusb",
    "libusbx",
    "libuser",
    "libuser-python",
    "libutempter",
    "libuuid",
    "libv4l",
    "libverto",
    "libverto-tevent",
    "libvirt-client",
    "libvirt-daemon",
    "libvirt-daemon-driver-interface",
    "libvirt-daemon-driver-network",
    "libvirt-daemon-driver-nodedev",
    "libvirt-daemon-driver-nwfilter",
    "libvirt-daemon-driver-qemu",
    "libvirt-daemon-driver-secret",
    "libvirt-daemon-driver-storage",
    "libvirt-daemon-kvm",
    "libvirt-gconfig",
    "libvirt-glib",
    "libvirt-gobject",
    "libvisio",
    "libvisual",
    "libvorbis",
    "libvpx",
    "libwacom",
    "libwacom-data",
    "libwbclient",
    "libwebp",
    "libwnck3",
    "libwpd",
    "libwpg",
    "libwps",
    "libwvstreams",
    "libX11",
    "libX11-common",
    "libXau",
    "libxcb",
    "libXcomposite",
    "libXcursor",
    "libXdamage",
    "libXdmcp",
    "libXevie",
    "libXext",
    "libXfixes",
    "libXfont",
    "libXft",
    "libXi",
    "libXinerama",
    "libxkbfile",
    "libxklavier",
    "libxml2",
    "libxml2-python",
    "libXmu",
    "libXpm",
    "libXrandr",
    "libXrender",
    "libXres",
    "libxslt",
    "libXt",
    "libXtst",
    "libXv",
    "libXvMC",
    "libXxf86dga",
    "libXxf86misc",
    "libXxf86vm",
    "libzapojit",
    "libzip",
    "linuxconsoletools",
    "linux-firmware",
    "lklug-fonts",
    "lldpad",
    "lm_sensors-libs",
    "lockdev",
    "logrotate",
    "lohit-assamese-fonts",
    "lohit-bengali-fonts",
    "lohit-devanagari-fonts",
    "lohit-gujarati-fonts",
    "lohit-kannada-fonts",
    "lohit-malayalam-fonts",
    "lohit-marathi-fonts",
    "lohit-nepali-fonts",
    "lohit-oriya-fonts",
    "lohit-punjabi-fonts",
    "lohit-tamil-fonts",
    "lohit-telugu-fonts",
    "lpsolve",
    "lrzsz",
    "lsof",
    "lua",
    "lvm2",
    "lvm2-libs",
    "lzo",
    "lzop",
    "m17n-contrib",
    "m17n-db",
    "m17n-lib",
    "madan-fonts",
    "mailcap",
    "mailx",
    "make",
    "man-db",
    "man-pages",
    "man-pages-overrides",
    "mariadb",
    "mariadb-libs",
    "mariadb-server",
    "marisa",
    "mdadm",
    "meanwhile",
    "media-player-info",
    "mesa-dri-drivers",
    "mesa-filesystem",
    "mesa-libEGL",
    "mesa-libgbm",
    "mesa-libGL",
    "mesa-libglapi",
    "mesa-libxatracker",
    "mesa-private-llvm",
    "metacity",
    "microcode_ctl",
    "mlocate",
    "mobile-broadband-provider-info",
    "ModemManager",
    "ModemManager-glib",
    "mokutil",
    "mousetweaks",
    "mozilla-filesystem",
    "mozjs17",
    "mpfr",
    "mtdev",
    "mtools",
    "mtr",
    "mutter",
    "mythes",
    "nano",
    "nautilus",
    "nautilus-extensions",
    "nautilus-open-terminal",
    "nautilus-sendto",
    "ncurses",
    "ncurses-base",
    "ncurses-libs",
    "neon",
    "netcf-libs",
    "net-snmp",
    "net-snmp-agent-libs",
    "net-snmp-libs",
    "nettle",
    "net-tools",
    "NetworkManager",
    "NetworkManager-glib",
    "NetworkManager-libreswan",
    "NetworkManager-tui",
    "newt",
    "newt-python",
    "nfs4-acl-tools",
    "nhn-nanum-fonts-common",
    "nhn-nanum-gothic-fonts",
    "nmap-ncat",
    "nm-connection-editor",
    "nspr",
    "nss",
    "nss-softokn",
    "nss-softokn-freebl",
    "nss-sysinit",
    "nss-tools",
    "nss-util",
    "ntsysv",
    "numactl-libs",
    "numad",
    "obexd",
    "oddjob",
    "oddjob-mkhomedir",
    "opal",
    "opencc",
    "openchange",
    "openjpeg-libs",
    "openldap",
    "openssh",
    "openssh-clients",
    "openssh-server",
    "openssl",
    "openssl-libs",
    "open-vm-tools",
    "open-vm-tools-desktop",
    "opus",
    "orc",
    "orca",
    "os-prober",
    "overpass-fonts",
    "p11-kit",
    "p11-kit-trust",
    "PackageKit",
    "PackageKit-command-not-found",
    "PackageKit-device-rebind",
    "PackageKit-glib",
    "PackageKit-gstreamer-plugin",
    "PackageKit-gtk3-module",
    "PackageKit-yum",
    "pakchois",
    "paktype-naskh-basic-fonts",
    "pam",
    "pam_krb5",
    "pango",
    "pangomm",
    "paps",
    "paps-libs",
    "paratype-pt-sans-fonts",
    "parted",
    "passwd",
    "pciutils",
    "pciutils-libs",
    "pcre",
    "pcsc-lite-libs",
    "perl",
    "perl-Carp",
    "perl-Compress-Raw-Bzip2",
    "perl-Compress-Raw-Zlib",
    "perl-constant",
    "perl-Data-Dumper",
    "perl-DBD-MySQL",
    "perl-DBI",
    "perl-Encode",
    "perl-Error",
    "perl-Exporter",
    "perl-File-Path",
    "perl-File-Temp",
    "perl-Filter",
    "perl-Getopt-Long",
    "perl-Git",
    "perl-HTTP-Tiny",
    "perl-IO-Compress",
    "perl-libs",
    "perl-macros",
    "perl-Net-Daemon",
    "perl-parent",
    "perl-PathTools",
    "perl-PlRPC",
    "perl-Pod-Escapes",
    "perl-podlators",
    "perl-Pod-Perldoc",
    "perl-Pod-Simple",
    "perl-Pod-Usage",
    "perl-Scalar-List-Utils",
    "perl-Socket",
    "perl-Storable",
    "perl-TermReadKey",
    "perl-Text-ParseWords",
    "perl-threads",
    "perl-threads-shared",
    "perl-Time-Local",
    "php",
    "php-bcmath",
    "php-cli",
    "php-common",
    "php-gd",
    "php-ldap",
    "php-mbstring",
    "php-mcrypt",
    "phpMyAdmin",
    "php-mysql",
    "php-odbc",
    "php-pdo",
    "php-pear",
    "php-php-gettext",
    "php-process",
    "php-snmp",
    "php-soap",
    "php-tcpdf",
    "php-tcpdf-dejavu-sans-fonts",
    "php-tidy",
    "php-xml",
    "php-xmlrpc",
    "pinentry",
    "pinentry-gtk",
    "pinfo",
    "pixman",
    "pkgconfig",
    "plymouth",
    "plymouth-core-libs",
    "plymouth-graphics-libs",
    "plymouth-plugin-label",
    "plymouth-plugin-two-step",
    "plymouth-scripts",
    "plymouth-system-theme",
    "plymouth-theme-charge",
    "pm-utils",
    "pnm2ppa",
    "policycoreutils",
    "policycoreutils-python",
    "polkit",
    "polkit-pkla-compat",
    "poppler",
    "poppler-data",
    "poppler-glib",
    "poppler-utils",
    "popt",
    "postfix",
    "ppp",
    "procps-ng",
    "psacct",
    "psmisc",
    "pth",
    "ptlib",
    "pulseaudio",
    "pulseaudio-gdm-hooks",
    "pulseaudio-libs",
    "pulseaudio-libs-glib2",
    "pulseaudio-module-bluetooth",
    "pulseaudio-module-x11",
    "pulseaudio-utils",
    "pyatspi",
    "pycairo",
    "pygobject2",
    "pygobject3",
    "pygobject3-base",
    "pygpgme",
    "pygtk2",
    "pygtk2-libglade",
    "pykickstart",
    "pyliblzma",
    "pyOpenSSL",
    "pyparsing",
    "pyparted",
    "pytalloc",
    "python",
    "python-augeas",
    "python-backports",
    "python-backports-ssl_match_hostname",
    "python-beaker",
    "python-blivet",
    "python-brlapi",
    "python-caribou",
    "python-chardet",
    "python-configobj",
    "python-configshell",
    "python-coverage",
    "python-cups",
    "python-decorator",
    "python-deltarpm",
    "python-di",
    "python-dns",
    "python-ethtool",
    "python-iniparse",
    "python-inotify",
    "python-IPy",
    "python-javapackages",
    "python-kerberos",
    "python-kitchen",
    "python-kmod",
    "python-krbV",
    "python-ldap",
    "python-libs",
    "python-lxml",
    "python-mako",
    "python-markupsafe",
    "python-meh",
    "python-netaddr",
    "python-nss",
    "python-paste",
    "python-pwquality",
    "python-pyblock",
    "python-pycurl",
    "python-pyudev",
    "python-rtslib",
    "python-setuptools",
    "python-slip",
    "python-slip-dbus",
    "python-sssdconfig",
    "python-tempita",
    "python-urlgrabber",
    "python-urwid",
    "pytz",
    "pyxattr",
    "qemu-guest-agent",
    "qemu-img",
    "qemu-kvm",
    "qemu-kvm-common",
    "qpdf-libs",
    "qrencode-libs",
    "quota",
    "quota-nls",
    "radvd",
    "raptor2",
    "rarian",
    "rarian-compat",
    "rasqal",
    "rdate",
    "readline",
    "realmd",
    "redhat-menus",
    "redland",
    "rest",
    "rfkill",
    "rhino",
    "rhythmbox",
    "rng-tools",
    "rootfiles",
    "rpcbind",
    "rpm",
    "rpm-build-libs",
    "rpm-libs",
    "rpm-python",
    "rsync",
    "rsyslog",
    "rsyslog-mmjsonparse",
    "rtkit",
    "sane-backends",
    "sane-backends-drivers-scanners",
    "sane-backends-libs",
    "satyr",
    "sbc",
    "scl-utils",
    "SDL",
    "seabios-bin",
    "seahorse",
    "seavgabios-bin",
    "sed",
    "selinux-policy",
    "selinux-policy-targeted",
    "setools-libs",
    "setroubleshoot",
    "setroubleshoot-plugins",
    "setroubleshoot-server",
    "setserial",
    "setup",
    "setuptool",
    "sg3_utils-libs",
    "sgabios-bin",
    "sgpio",
    "shadow-utils",
    "shared-mime-info",
    "shim",
    "shim-unsigned",
    "shotwell",
    "sil-abyssinica-fonts",
    "sil-nuosu-fonts",
    "sil-padauk-fonts",
    "skkdic",
    "slang",
    "smartmontools",
    "smc-fonts-common",
    "smc-meera-fonts",
    "snappy",
    "sos",
    "sound-theme-freedesktop",
    "soundtouch",
    "sox",
    "speech-dispatcher",
    "speech-dispatcher-python",
    "speex",
    "spice-glib",
    "spice-gtk3",
    "spice-server",
    "spice-vdagent",
    "sqlite",
    "sssd",
    "sssd-ad",
    "sssd-client",
    "sssd-common",
    "sssd-common-pac",
    "sssd-ipa",
    "sssd-krb5",
    "sssd-krb5-common",
    "sssd-ldap",
    "sssd-proxy",
    "startup-notification",
    "stix-fonts",
    "strace",
    "sudo",
    "sushi",
    "SYMCnbclt",
    "SYMCnbjava",
    "SYMCnbjre",
    "SYMCpddea",
    "syslinux",
    "sysstat",
    "system-config-keyboard",
    "system-config-keyboard-base",
    "system-config-printer",
    "system-config-printer-libs",
    "system-config-printer-udev",
    "systemd",
    "systemd-libs",
    "systemd-python",
    "systemd-sysv",
    "systemtap-runtime",
    "sysvinit-tools",
    "t1lib",
    "taglib",
    "tar",
    "targetcli",
    "tcpdump",
    "tcp_wrappers",
    "tcp_wrappers-libs",
    "tcsh",
    "teamd",
    "telepathy-farstream",
    "telepathy-filesystem",
    "telepathy-gabble",
    "telepathy-glib",
    "telepathy-haze",
    "telepathy-logger",
    "telepathy-mission-control",
    "telepathy-salut",
    "thai-scalable-fonts-common",
    "thai-scalable-waree-fonts",
    "tigervnc-license",
    "tigervnc-server",
    "tigervnc-server-minimal",
    "time",
    "totem",
    "totem-mozplugin",
    "totem-nautilus",
    "totem-pl-parser",
    "traceroute",
    "tracker",
    "ttmkfdir",
    "tuned",
    "tzdata",
    "tzdata-java",
    "ucs-miscfixed-fonts",
    "udisks2",
    "unbound-libs",
    "unixODBC",
    "unoconv",
    "unzip",
    "upower",
    "urw-fonts",
    "usb_modeswitch",
    "usb_modeswitch-data",
    "usbmuxd",
    "usbredir",
    "usbutils",
    "usermode",
    "ustr",
    "util-linux",
    "vim-common",
    "vim-enhanced",
    "vim-filesystem",
    "vim-minimal",
    "vinagre",
    "vino",
    "virt-what",
    "vlgothic-fonts",
    "vorbis-tools",
    "VRTSpbx",
    "vte3",
    "wavpack",
    "webkitgtk3",
    "webrtc-audio-processing",
    "wget",
    "which",
    "wodim",
    "words",
    "wpa_supplicant",
    "wqy-microhei-fonts",
    "wqy-zenhei-fonts",
    "wvdial",
    "xcb-util",
    "xdg-user-dirs",
    "xdg-user-dirs-gtk",
    "xdg-utils",
    "xfsdump",
    "xfsprogs",
    "xkeyboard-config",
    "xml-common",
    "xmlrpc-c",
    "xmlrpc-c-client",
    "xorg-x11-drivers",
    "xorg-x11-drv-ati",
    "xorg-x11-drv-dummy",
    "xorg-x11-drv-evdev",
    "xorg-x11-drv-fbdev",
    "xorg-x11-drv-intel",
    "xorg-x11-drv-modesetting",
    "xorg-x11-drv-nouveau",
    "xorg-x11-drv-qxl",
    "xorg-x11-drv-synaptics",
    "xorg-x11-drv-v4l",
    "xorg-x11-drv-vesa",
    "xorg-x11-drv-vmmouse",
    "xorg-x11-drv-vmware",
    "xorg-x11-drv-void",
    "xorg-x11-drv-wacom",
    "xorg-x11-fonts-Type1",
    "xorg-x11-font-utils",
    "xorg-x11-glamor",
    "xorg-x11-server-common",
    "xorg-x11-server-utils",
    "xorg-x11-server-Xorg",
    "xorg-x11-utils",
    "xorg-x11-xauth",
    "xorg-x11-xinit",
    "xorg-x11-xkb-utils",
    "xvattr",
    "xz",
    "xz-libs",
    "yajl",
    "yelp",
    "yelp-libs",
    "yelp-xsl",
    "ypbind",
    "yp-tools",
    "yum",
    "yum-langpacks",
    "yum-metadata-parser",
    "yum-plugin-fastestmirror",
    "yum-utils",
    "zenity",
    "zip",
    "zlib",]:
    ensure => 'installed';
  }

}