{
  description = "My custom Nix packages";

  nixConfig = {
    extra-substituters = [ "https://forester.cachix.org" ];
    extra-trusted-public-keys = [
      "forester.cachix.org-1:pErGVVci7kZWxxcbQ/To8Lvqp6nVTeyPf0efJxbrQDM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # opam-nix builds OCaml packages from opam metadata. Forester (a sourcehut
    # OCaml project) doesn't ship in nixpkgs, so we lift its build by feeding
    # its dune project through opam-nix and selecting the resulting binary.
    # The pinned opam-repository snapshot is fetched inside the package that
    # needs it (see packages/forester/default.nix) rather than as a global
    # flake input, so each OCaml package can carry its own repo pin without
    # accumulating top-level inputs.
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      opam-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = import ./packages {
          inherit pkgs;
          inherit (pkgs) callPackage;
          opamNixLib = opam-nix.lib.${system};
        };
      }
    );
}
