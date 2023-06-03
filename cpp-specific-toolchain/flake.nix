{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };
  outputs = {
    self
    , nixpkgs
  }:
  let
    system = "x86_64-linux";

    pkgs = let
      origPkgs = import nixpkgs { inherit system; };

      getCustomGccStdenv = customGccNixpkgs: origStdenv: { pkgs, ... }:
        with pkgs; let
          gcc_custom = customGccNixpkgs.gcc-unwrapped;
          compilerWrapped = wrapCCWith {
            cc = gcc_custom;
            bintools = wrapBintoolsWith {
              bintools = binutils-unwrapped;
              libc = glibc;
            };
          };
        in
          overrideCC origStdenv compilerWrapped;

      getGcc830Stdenv =
        let
          gcc830Nixpkgs = import (builtins.fetchGit {
             name = "gcc_8_3_0";
             url = "https://github.com/NixOS/nixpkgs/";
             ref = "refs/heads/nixpkgs-unstable";
             rev = "a9eb3eed170fa916e0a8364e5227ee661af76fde";
          }) { inherit system; };
        in getCustomGccStdenv gcc830Nixpkgs origPkgs.gcc8Stdenv;

      # getGcc830Stdenv = { pkgs, ... }:
      #   with pkgs;
      #   let
      #     gcc_8_3_0 = (import (builtins.fetchGit {
      #        name = "gcc_8_3_0";
      #        url = "https://github.com/NixOS/nixpkgs/";
      #        ref = "refs/heads/nixpkgs-unstable";
      #        rev = "a9eb3eed170fa916e0a8364e5227ee661af76fde";
      #     }) { inherit system; }).gcc-unwrapped;

      #     # glibcPkgs = import (builtins.fetchTarball {
      #     #   url = "https://github.com/NixOS/nixpkgs/archive/a9eb3eed170fa916e0a8364e5227ee661af76fde.tar.gz";
      #     #   sha256 = "0zfkymyg0l5ihnyj1nlm14fs7z109ah6hbid7l0i3f0g80s1pbq2";
      #     # }) { system = system; };
      #     # glibc_2_18 = glibcPkgs.glibc;
      #     # glibc = pkgs.glibc.overrideAttrs (attrs:
      #     #   let old-glibc = (import glibcPkgs {inherit system;}).glibc;
      #     #   in {
      #     #     inherit (old-glibc) name src postPatch patches;
      #     #   }
      #     # );
      #     compilerUnwrapped = gcc_8_3_0;
      #     compilerWrapped = wrapCCWith {
      #       cc = compilerUnwrapped;
      #       bintools = wrapBintoolsWith {
      #         bintools = binutils-unwrapped;
      #         # libc = glibc;
      #       };
      #     };
      #   in
      #     (overrideCC gcc8Stdenv compilerWrapped);
      overlays = [
        (self: super: {
          gcc830Stdenv = getGcc830Stdenv super;
          # gcc920Stdenv = getGcc920Stdenv super;
        } )
      ];
    in
      origPkgs.appendOverlays overlays;

    mainPkg830 = pkgs.callPackage ./main.nix { customStdenv = pkgs.gcc830Stdenv; };
    # mainPkg920 = pkgs.callPackage ./main.nix { customStdenv = pkgs.gcc920Stdenv; };
    mainPkg = pkgs.callPackage ./main.nix { customStdenv = pkgs.stdenv; };

    getShowGlibcReqsApp = pkg:
      let prog = pkgs.writeShellScriptBin
        "show_glibc_reqs"
        ''
          ${pkgs.bintools}/bin/readelf --dyn-syms ${pkg}/bin/main | grep '@GLIBC'
        '';
       in {
         type = "app";
         program = "${prog}/bin/show_glibc_reqs";
       };
  in {
    packages.${system} = {
      main = mainPkg;
      main830 = mainPkg830;
    };
    apps.${system} = {
      show_glibc_reqs_830 = getShowGlibcReqsApp mainPkg830;
      show_glibc_reqs_std = getShowGlibcReqsApp mainPkg;
    };
  };
}
