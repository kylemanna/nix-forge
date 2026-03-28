final: prev: {
  "116xfwdl" = final.callPackage ./packages/116xfwdl/package.nix { };

  aoostar-rs = final.callPackage ./packages/aoostar-rs/package.nix { };

  code-cursor = final.callPackage ./packages/code-cursor/package.nix {
    vscode-generic = final.callPackage "${prev.path}/pkgs/applications/editors/vscode/generic.nix" { };
  };

  intel-lpmd = final.callPackage ./packages/intel-lpmd/package.nix { };
}
