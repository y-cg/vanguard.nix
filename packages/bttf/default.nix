{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bttf";
  version = "0.1.4";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "bttf";
    tag = finalAttrs.version;
    hash = "sha256-KB9ix/4UTNoxXAT+EuCtcjjFKurwPYrYBcx4H2ctv/E=";
  };

  # importCargoLock uses fetchCrate (static.crates.io) instead of
  # fetchCargoVendor, which avoids crates.io 403s from GitHub Actions IPs.
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  # nixpkgs ships rustc 1.91; upstream declares 1.93 as MSRV.
  postPatch = ''
    substituteInPlace Cargo.toml --replace-fail 'rust-version = "1.93"' 'rust-version = "1.91"'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A command line tool for datetime arithmetic, parsing, formatting and more";
    homepage = "https://github.com/BurntSushi/bttf";
    changelog = "https://github.com/BurntSushi/bttf/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bttf";
  };
})
