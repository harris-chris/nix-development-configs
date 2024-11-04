{
  description = "clash-environment-test";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clash-compiler.url = "github:clash-lang/clash-compiler";
  };

  outputs = {
    self
    , nixpkgs
    , clash-compiler
  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ clash-compiler.overlays.default ];
      };
      inherit (pkgs) lib;
    in
    {
      devShells.${system} = {
        default = clash-compiler.devShells.${system}.default;
      };
      packages.${system} = {
        # adm_pcie_9v3_10g = with pkgs; callPackage ./nix/adm_pcie_9v3.nix { build10g = true; };
      };
    };
}
