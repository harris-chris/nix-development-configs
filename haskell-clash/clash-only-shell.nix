{ pkgs ?  import <nixos> {} }:
let
  unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {};
in pkgs.mkShell {
  name = "clash-compiler-shell";
  buildInputs = with unstable.haskellPackages; [
    (ghcWithPackages (p: with p; [
      clash-ghc

      ghc-typelits-extra
      ghc-typelits-knownnat
      ghc-typelits-natnormalise
    ])
    )
  ];
}
