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
    origPkgs = import nixpkgs { inherit system; };

    oldTools = {
      gcc830 = (import (builtins.fetchGit {
         name = "gcc830";
         url = "https://github.com/NixOS/nixpkgs/";
         ref = "refs/heads/nixpkgs-unstable";
         rev = "a9eb3eed170fa916e0a8364e5227ee661af76fde";
      }) { inherit system; }).gcc-unwrapped;
      gcc920 = (import (builtins.fetchGit {
         name = "gcc920";
         url = "https://github.com/NixOS/nixpkgs/";
         ref = "refs/heads/nixpkgs-unstable";
         rev = "9d21fe813fd96afd4a08d5437186ebe438546693";
      }) { inherit system; }).gcc-unwrapped;
      glibc218 = (import (builtins.fetchGit {
         name = "glibc_2_18";
         url = "https://github.com/NixOS/nixpkgs/";
         ref = "refs/heads/nixpkgs-unstable";
         rev = "ab6453c483e406b07c63503bca5038838c187ecf";
      }) { inherit system; }).glibc;
    };

    getStdenvs = origPkgs:
      with oldTools;
      let
        getCustomGccStdenv = customGcc: customGlibc: origStdenv: { pkgs, ... }:
          with pkgs; let
            compilerWrapped = wrapCCWith {
              cc = customGcc;
              bintools = wrapBintoolsWith {
                bintools = binutils-unwrapped;
                libc = customGlibc;
              };
            };
          in
            overrideCC origStdenv compilerWrapped;
      in {
        gcc830Glibc218 = getCustomGccStdenv
          gcc830 glibc218 origPkgs.stdenv origPkgs;
        gcc830Glibc237 = getCustomGccStdenv
          gcc830 origPkgs.glibc origPkgs.stdenv origPkgs;
        gcc920Glibc237 = getCustomGccStdenv
          gcc920 origPkgs.glibc origPkgs.stdenv origPkgs;
      };

    getOverlays = origPkgs:
      let
        stdenvOverlays = getStdenvs origPkgs;
      in [
        (self: super: getStdenvs origPkgs )
      ];

    getPackages = origPkgs:
      let
        envs = getStdenvs origPkgs;
        pkgs = origPkgs.appendOverlays (getOverlays origPkgs);
        envToPkg = envName: env:
          let pkgName = "pkgGcc${( pkgs.lib.strings.removePrefix "gcc" envName )}";
          in { name = pkgName; value = pkgs.callPackage ./main.nix { stdenv = env; }; };
      in
        origPkgs.lib.attrsets.mapAttrs' envToPkg envs;

    getShowGlibcApps = pkgs:
      let
        packages = getPackages pkgs;
        pkgToApp = pkgName: pkg:
          let
            prog = origPkgs.writeShellScriptBin
              "show_glibc_reqs"
              ''
                ${origPkgs.bintools}/bin/readelf --dyn-syms ${pkg}/bin/main | grep '@GLIBC'
              '';
            appName = "show_glibc_reqs_${(pkgs.lib.strings.removePrefix "pkg" pkgName)}";
            app =
              { type = "app";
              program = "${prog}/bin/show_glibc_reqs"; };
          in { name = appName; value = app; };
      in pkgs.lib.attrsets.mapAttrs' pkgToApp packages;
  in {
    packages.${system} = getPackages origPkgs;
    apps.${system} = getShowGlibcApps origPkgs;
  };
}
