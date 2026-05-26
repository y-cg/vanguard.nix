{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
}:
let
  version = "2.24.0";
in
rustPlatform.buildRustPackage {
  pname = "lumen";
  inherit version;

  src = fetchFromGitHub {
    owner = "jnsahaj";
    repo = "lumen";
    rev = "v${version}";
    hash = "sha256-1cRtki1WYPBP6594VfzI9bUc5JUZe9VDzaQhb21BHK4=";
  };

  cargoHash = "sha256-QxVNwWr4t1uOZbTE4UtYzf5htkSovlxwbBsW+Pa11M8=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    openssl
  ];

  doCheck = false;

  patches = [ ./patches/00-openai-compatible.patch ];

  meta = with lib; {
    description = "Beautiful git diff viewer, generate commits with AI, get summary of changes, all from the CLI";
    homepage = "https://github.com/jnsahaj/lumen";
    license = licenses.mit;
    mainProgram = "lumen";
    platforms = platforms.all;
  };
}
