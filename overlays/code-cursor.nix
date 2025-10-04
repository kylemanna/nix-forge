# Code Cursor overlay - AI-powered code editor
final: prev:

{
  code-cursor = prev.callPackage ../packages/code-cursor/package.nix {
    vscode-generic = "${prev.path}/pkgs/applications/editors/vscode/generic.nix";
  };
}
