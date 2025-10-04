{
  description = "Nix Forge - Custom Nix overlay providing various packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      # Aggregate all individual overlays
      aggregateOverlays = final: prev:
        with prev.lib;
        let
          overlayList = map import (import ./overlays.nix);
        in
          foldl' (flip extends) (_: prev) overlayList final;
    in
    {
      # Default overlay (aggregates all individual overlays)
      overlays.default = aggregateOverlays;
    };
}
