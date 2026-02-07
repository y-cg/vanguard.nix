{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
}:
let
  version = "2.20.0";
in
rustPlatform.buildRustPackage {
  pname = "lumen";
  inherit version;

  src = fetchFromGitHub {
    owner = "jnsahaj";
    repo = "lumen";
    rev = "v${version}";
    hash = "sha256-05/0u2AcOat3zitnoE9PBZTiRC1tuVhcGSWltjjA0i4=";
  };

  cargoHash = "sha256-N8i9qiEn86QRUM1hBvp12tvOh6JE7Kzf9eOaAjfw7tY=";

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
