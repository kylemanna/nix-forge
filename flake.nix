{
  description = "Nix Forge - Custom Nix overlay providing various packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
    in
    {
      # Default overlay
      overlays.default = import ./overlays.nix;

      # NixOS modules
      nixosModules = {
        intel-lpmd = import ./modules/intel-lpmd.nix;
      };

      # Expose packages for each system
      packages = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          # Get the package names from the overlay to expose them in 'packages'
          # We call the overlay with empty sets just to get the keys
          overlayKeys = builtins.attrNames (self.overlays.default pkgs pkgs);
        in
        lib.genAttrs overlayKeys (name: pkgs.${name})
      );
    };
}
