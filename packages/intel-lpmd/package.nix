{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  gtk-doc,
  glib,
  libxml2,
  libnl,
  systemd,
  upower,
}:

stdenv.mkDerivation rec {
  pname = "intel-lpmd";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-lpmd";
    rev = "v${version}";
    sha256 = "0h3460n57p2mbsnhshlvjxw58gnsl66y25d6ga1x9dbnjid6143r";
  };
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gtk-doc
  ];

  buildInputs = [
    glib
    libxml2
    libnl
    systemd
    upower
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-werror"
    "--localstatedir=/var" # Insists on creating a pid lockfile
    "--with-dbus-sys-dir=${placeholder "out"}/etc/dbus-1/system.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  postPatch = ''
        substituteInPlace data/intel_lpmd.service.in \
          --replace "PrivateTmp=yes" "PrivateTmp=yes
    RuntimeDirectory=intel_lpmd"

        substituteInPlace data/Makefile.am \
          --replace $'systemdsystemunit_DATA = \\\n\tintel_lpmd.service' \
          $'systemdsystemunit_DATA = \\\n\tintel-lpmd.service'

        substituteInPlace data/Makefile.am \
          --replace "intel_lpmd.service: intel_lpmd.service.in" \
          "intel-lpmd.service: intel_lpmd.service.in"

        substituteInPlace data/Makefile.am \
          --replace "CLEANFILES = intel_lpmd.service org.freedesktop.intel_lpmd.service" \
          "CLEANFILES = intel-lpmd.service org.freedesktop.intel_lpmd.service"
  '';

  meta = {
    description = "Intel Low Power Mode Daemon for optimizing active idle power";
    homepage = "https://github.com/intel/intel-lpmd";
    changelog = "https://github.com/intel/intel-lpmd/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
