{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cloudflare-speed-cli";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "kavehtehrani";
    repo = "cloudflare-speed-cli";
    rev = "v${version}";
    hash = "sha256-T2Hb491A0JlxH/jbHWH/ZeThiV66IURYqY/U2Q1w16Q=";
  };

  doCheck = false;
  cargoHash = "sha256-YP5mmkM/vXDwr5cGbUPEQR/KFwbnCGZ+9do6GjUd88s=";

  meta = {
    description = "CLI for internet speed test via cloudflare";
    homepage = "https://github.com/kavehtehrani/cloudflare-speed-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cloudflare-speed-cli";
  };
}
