{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "envelope";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "mattrighetti";
    repo = "envelope";
    rev = version;
    hash = "sha256-/DLQoVVF/vl/ZiIyeFFVoi7jnlYJaUmQxDbKXZFwRSk=";
  };

  cargoHash = "sha256-R/80M0Fo7vcgXbM2ptRw3Sp/3XygpFGl3kXcc/M9jkU=";

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
