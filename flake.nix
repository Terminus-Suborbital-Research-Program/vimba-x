{
  description = "Flake for Vimba-X drivers, libraries, and SDK";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        vimbax = pkgs.callPackage ./vimbax.nix { };
        vmbpy = pkgs.callPackage ./vmbpy.nix { inherit vimbax; };
      in {
        packages = {
          inherit vimbax vmbpy;
          default = vimbax;
        };

        devShells.default = pkgs.mkShell {
          packages = [ (pkgs.python312.withPackages (ps: [ vmbpy ])) ];
        };
      });
}

