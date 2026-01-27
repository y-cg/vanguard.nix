{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
}:
let
  version = "2.18.0";
in
rustPlatform.buildRustPackage {
  pname = "lumen";
  inherit version;

  src = fetchFromGitHub {
    owner = "jnsahaj";
    repo = "lumen";
    rev = "v${version}";
    hash = "sha256-2nNO5f+WMwQqaUFEa8W89ZRi3cuL7XPVbKHa67tB1gY=";
  };

  cargoHash = "sha256-awtjku2W7FsVRPOYJ8qocRl7H+6GNVk2iFgXTJrc3OY=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    openssl
  ];

  doCheck = false;

  patches = [ ./patches/00-poe-endpoint.patch ];

  meta = with lib; {
    description = "Beautiful git diff viewer, generate commits with AI, get summary of changes, all from the CLI";
    homepage = "https://github.com/jnsahaj/lumen";
    license = licenses.mit;
    mainProgram = "lumen";
    platforms = platforms.all;
  };
}
