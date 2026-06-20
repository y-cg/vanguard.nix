# Forester is a tool for tending mathematical forests, distributed as an
# OCaml/dune project on sourcehut. It isn't packaged in nixpkgs, so we use
# opam-nix to materialise its full opam dependency graph and let dune build
# it the way upstream does.
#
# The upstream flake ships a static (musl) cross-compile path; we deliberately
# omit it here because the user only needs a native build and the cross
# infra adds a lot of failure surface on darwin.

{
  pkgs,
  opamNixLib,
  fetchgit,
  lib,
}:

let
  pname = "forester";
  version = "5.0";

  # Pinned to a known-good upstream commit. Bump together with the hash
  # whenever you want to follow new releases.
  src = fetchgit {
    url = "https://git.sr.ht/~jonsterling/ocaml-forester";
    rev = "5ab7277c8f8528fd8825dfccd5583c64b8751e5e";
    hash = "sha256-dmwfNVLlZaKo5e8khzObPo1t1eNVExnhpHJnV1255kI=";
  };

  # Force opam-nix to build OCaml 5.3 from source rather than using whatever
  # ocaml-system nixpkgs ships. The latest nixpkgs has OCaml 5.4, but
  # forester 5.0 transitively pins bisect_ppx ≥ 2.8.3 which requires
  # ppxlib < 0.36 which requires OCaml < 5.4 — using ocaml-system would
  # leave the solver with no valid resolution.
  query = {
    ocaml-base-compiler = "5.3.0";
  };

  scope = opamNixLib.buildDuneProject { inherit pkgs; } pname src query;

  # Targeted overlay over opam-nix's generated scope:
  #   * forester itself: turn off doNixSupport (opam-nix's nix-support hook
  #     trips on dune-site shares), and on darwin add `sigtool` so dune's
  #     code-signing step can find a `codesign` shim.
  #   * ocamlgraph: opam-nix tries `make` by default but ocamlgraph in the
  #     dune ecosystem expects `dune build -p ocamlgraph`.
  overlay = final: prev: {
    ${pname} = prev.${pname}.overrideAttrs (oldAttrs: {
      doNixSupport = false;
      nativeBuildInputs =
        (oldAttrs.nativeBuildInputs or [ ]) ++ lib.optional pkgs.stdenv.isDarwin pkgs.darwin.sigtool;
    });
    ocamlgraph = prev.ocamlgraph.overrideAttrs (_: {
      buildPhase = "dune build -p ocamlgraph -j $NIX_BUILD_CORES";
    });
  };

  scope' = scope.overrideScope overlay;
in
scope'.${pname}.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "A tool for tending mathematical forests";
    homepage = "https://sr.ht/~jonsterling/forester/";
    license = lib.licenses.gpl3Plus;
    mainProgram = "forester";
    platforms = lib.platforms.unix;
  };
})
