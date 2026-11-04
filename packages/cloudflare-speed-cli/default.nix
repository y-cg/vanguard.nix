{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cloudflare-speed-cli";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "kavehtehrani";
    repo = "cloudflare-speed-cli";
    rev = "v${version}";
    hash = "sha256-xZsAwUED3xvhme0KSJAFFUGth081c85S36x3jsnebS4=";
  };

  doCheck = false;
  cargoHash = "sha256-QrYrKXh5hZYDC5IGho/xEgeXT2W2ohUXcP0qjZIsIs0=";

  meta = {
    description = "CLI for internet speed test via cloudflare";
    homepage = "https://github.com/kavehtehrani/cloudflare-speed-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cloudflare-speed-cli";
  };
}
