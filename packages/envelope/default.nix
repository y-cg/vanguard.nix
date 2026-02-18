{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "envelope";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "mattrighetti";
    repo = "envelope";
    rev = version;
    hash = "sha256-iV0HHZQbTOvEkfVM+tckM3cAkWE2SPq4GpyvCLCdMkE=";
  };

  cargoHash = "sha256-oJYJYESg7Z2p1lQ6n1d3xSM+yl0VfyMg38wzykGJnUM=";

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
