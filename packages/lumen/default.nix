{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
}:
let
  version = "2.32.0";
in
rustPlatform.buildRustPackage {
  pname = "lumen";
  inherit version;

  src = fetchFromGitHub {
    owner = "jnsahaj";
    repo = "lumen";
    rev = "v${version}";
    hash = "sha256-wTkg7NGCCON1P422q5/76rodIBqDeWIY07J4pRo8Q8k=";
  };

  cargoHash = "sha256-ZXw7KEvf1sUHWIM5R4Th2SmekTX6rGXznAq3mtcf3Zo=";

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
