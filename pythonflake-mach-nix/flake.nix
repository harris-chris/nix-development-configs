{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix = {
      url = "github:DavHau/mach-nix";
    };
  };
  outputs = { self, nixpkgs, flake-utils, mach-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        machNix = mach-nix.lib."${system}";

        packageName = "pythonflake-mach-nix";
        packageVersion = "0.1.0";

        customOverrides = self: super: { };

        requirements = ''
          plumbum
          dhall
        '';

        source_preferences = {
          _default = "nixpkgs,wheel,sdist";
          dhall = "wheel";
        };

        env = machNix.mkPython {
          inherit requirements;
          packagesExtra = [ pkgs.openssl ];
        };

        app = machNix.buildPythonApplication {
          pname = packageName;
          version = packageVersion;
          src = ./.;
          inherit requirements;
        };

      in {
        packages.${packageName} = app;

        devShell = pkgs.mkShell {
          buildInputs = [ env ];
          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.openssl.out}/lib
          '';
        };
        defaultPackage = self.packages.${system}.${packageName};
        apps.${system}.default = app;

      });
}
