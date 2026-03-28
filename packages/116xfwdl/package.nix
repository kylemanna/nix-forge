{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "116xfwdl";
  version = "1.1.1.0";

  src = fetchurl {
    url = "https://dl.radxa.com/accessories/m2-to-hexa-sata-adapter/tools/116xfwdl_bin_v1110_x86_64.zip";
    hash = "sha256-/eTd+tOv04zEXpxBEUSApmLL7tfPCw+7dlmuBKapux8=";
  };

  nativeBuildInputs = [ unzip ];

  # The zip contains a binary and a manual.
  # Exectuable: 116xfwdl
  # Manual: ASM116xfwdl_UserManual.pdf

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    install -Dm755 116xfwdl $out/bin/116xfwdl
  '';

  meta = {
    description = "Radxa M.2 to Hexa SATA adapter firmware downloader tool";
    longDescription = ''
      ASM1116 firmware downloader tool for Radxa M.2 to Hexa SATA adapter.
      Note: ASM1116 firmware with hot plug support is here: https://dl.radxa.com/accessories/m2-to-hexa-sata-adapter/tools/
    '';
    homepage = "https://radxa.com";
    license = lib.licenses.unfree; # Proprietary binary
    platforms = [ "x86_64-linux" ];
    mainProgram = "116xfwdl";
  };
}
