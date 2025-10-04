# Nix Forge

A custom Nix overlay providing various packages, following community best practices.

## Overview

This repository contains a Nixpkgs overlay that exposes customized versions of packages to override nixpkgs that are new, broken, or falling behind.

## Structure

- `flake.nix` - Flake definition that aggregates and outputs overlays
- `overlays.nix` - List of overlay files to aggregate
- `overlays/` - Directory containing individual overlay files
- `packages/` - Directory containing individual package definitions

## Usage

### As a Flake

Add to your flake inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-forge.url = "github:kylemanna/nix-forge";
    nix-forge.inputs.nixpkgs.follows = "nixpkgs"; # Override to use your nixpkgs
  };

  outputs = { nix-forge, ... }: {
    nixpkgs.overlays = [ nix-forge.overlays.default ];
  };
}
```

## Adding New Packages

1. Create your `package.nix` file in `packages/your-package/`
2. Create an individual overlay in `overlays/your-package.nix`:

```nix
# overlays/your-package.nix
final: prev: {
  your-package = prev.callPackage ../packages/your-package/package.nix { };
}
```

3. Add the overlay to `overlays.nix`:

```nix
# overlays.nix
[
  ./overlays/code-cursor.nix
  ./overlays/your-package.nix
]
```
