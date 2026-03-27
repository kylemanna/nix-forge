{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  systemd,
}:

rustPlatform.buildRustPackage rec {
  pname = "aoostar-rs";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "dev-zetta";
    repo = "aoostar-rs";
    rev = "v${version}";
    hash = "sha256-AUSTCOekVENVu0SnBvCZNxo6DqrzR2EyNwXY3BQpisY=";
  };

  cargoHash = "sha256-wHH/yqf0xnUXoa2RtDKAOPusyB45KkkyoFvP1Zi+XD4=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    systemd
  ];

  meta = {
    description = "CLI tool to control the secondary LCD display on AOOSTAR WTR MAX and GEM12+ PRO mini PCs";
    longDescription = ''
      aoostar-rs is a reverse-engineered Linux CLI tool that controls the secondary
      LCD screen found on the AOOSTAR WTR MAX and GEM12+ PRO mini PCs. It can power
      the screen on/off, display images, and render live hardware sensor panels
      (CPU temp, RAM usage, storage, fan speeds, etc.) on the device's 960x376
      secondary display.
    '';
    homepage = "https://github.com/dev-zetta/aoostar-rs"; # fork of https://github.com/zehnm/aoostar-rs
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "asterctl";
  };
}
