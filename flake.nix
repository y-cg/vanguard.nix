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
    #
    # opam-repository is pinned to the same commit the upstream forester flake
    # used so the opam solver picks the same dependency closure that's known
    # to compile against OCaml 5.3 (forester 5.0 transitively requires
    # bisect_ppx ≥ 2.8.3, which caps ppxlib < 0.36 and OCaml < 5.4 — bumping
    # the repo without a matching forester release breaks resolution).
    opam-repository = {
      url = "github:ocaml/opam-repository/a8a89f62d8abd2a9f0cbb04826bfec1ef6b563e7";
      flake = false;
    };
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.opam-repository.follows = "opam-repository";
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
