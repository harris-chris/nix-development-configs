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
        '';

        app = machNix.buildPythonApplication {
          pname = packageName;
          version = packageVersion;
          src = ./.;
          inherit requirements;
        };

      in {
        packages.${packageName} = app;

        defaultPackage = self.packages.${system}.${packageName};
        apps.${system}.default = app;

        devShell = machNix.mkPythonShell {
          inherit requirements;
        };
      });
}
