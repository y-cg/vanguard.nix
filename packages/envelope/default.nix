{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "envelope";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "mattrighetti";
    repo = "envelope";
    rev = version;
    hash = "sha256-GbZp0yijok5eiBJLVGDphJHOjpoburt9xYRwYHoE8uo=";
  };

  cargoHash = "sha256-ei6Ngapkszeo+1PbLv/ptwZjI8ksXuFthZi/idglg3M=";

  # Upstream MSRV is ahead of nixpkgs rustc; the crate still builds on our toolchain.
  postPatch = ''
    substituteInPlace Cargo.toml --replace 'rust-version = "1.97.1"' 'rust-version = "1.95.0"'
  '';

  meta = {
    description = "An environment variables cli tool backed by SQLite";
    homepage = "https://github.com/mattrighetti/envelope";
    changelog = "https://github.com/mattrighetti/envelope/blob/${src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      mit
      unlicense
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "envelope";
  };
}
