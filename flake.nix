{
  description = "Nix Forge - Custom Nix overlay providing various packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      # Aggregate all individual overlays
      aggregateOverlays =
        final: prev:
        with prev.lib;
        let
          overlayList = map import (import ./overlays.nix);
        in
        foldl' (flip extends) (_: prev) overlayList final;
    in
    {
      # Default overlay (aggregates all individual overlays)
      overlays.default = aggregateOverlays;

      # Expose packages for each system
      packages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          overlayedPkgs = pkgs.extend aggregateOverlays;
        in
        {
          code-cursor = overlayedPkgs.code-cursor;
        }
      );
    };
}
