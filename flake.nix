{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    satyxin.url = "github:SnO2WMaN/satyxin";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satyxin,
    ...
  } @ inputs:
    {
      satyxinPackages.large-number = import ./package.nix;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
          ];
        };
      in {
        packages = rec {
          satydist = pkgs.satyxin.buildSatydist {
            packages = [
              "fss"
              "sno2wman"
              "enumitem"
              "code-printer"
              "easytable"
            ];
            adhocPackages = with self.packages."${system}"; [
              # satyxin-package-large-number
            ];
          };

          document-example = pkgs.satyxin.buildDocument {
            inherit satydist;
            name = "main";
            src = ./example;
            entrypoint = "main.saty";
          };
        };
        packages.satyxin-package-large-number = pkgs.callPackage (import ./package.nix) {};
        packages.default = self.packages."${system}".satyxin-package-large-number;
        defaultPackage = self.packages."${system}".default;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
