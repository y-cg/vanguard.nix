{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
}:
let
  version = "2.30.0";
in
rustPlatform.buildRustPackage {
  pname = "lumen";
  inherit version;

  src = fetchFromGitHub {
    owner = "jnsahaj";
    repo = "lumen";
    rev = "v${version}";
    hash = "sha256-EoxMYlWHmuprjjhvj3GyCxGDIcT/d+JMda9j75pqs+k=";
  };

  cargoHash = "sha256-qTFRfy+Wutee5SbaMaqcYjXgr6xZKYYBIuyVA7jAGiY=";

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
