{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "ssd-flash-id";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "pseudolabel";
    repo = "ssd-flash-id";
    rev = "6f2669eda74ad414669a57f16023a84b6c170ff2";
    hash = "sha256-AA+57wuZ+FMRvC0vm/EfKa4LiBGCv4G1IdAc5rM0doY=";
  };

  cargoHash = "sha256-ugrnik+dcl6NphYFxylEGJ6Bjrv+tODtqUN+n8gHt1k=";

  meta = {
    description = "Identify NAND flash chips on NVMe and SATA SSDs via vendor-specific commands";
    homepage = "https://github.com/pseudolabel/ssd-flash-id";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ssd-flash-id";
  };
}
