{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.intel-lpmd;
in
{
  options.services.intel-lpmd = {
    enable = lib.mkEnableOption "Intel Low Power Mode Daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.intel-lpmd;
      description = "The intel-lpmd package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.upower.enable = true;
    systemd.packages = [ cfg.package ];
    systemd.services.intel-lpmd.wantedBy = [ "multi-user.target" ];

    environment.etc."intel_lpmd".source = "${cfg.package}/etc/intel_lpmd";
  };
}
