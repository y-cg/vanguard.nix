{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cloudflare-speed-cli";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "kavehtehrani";
    repo = "cloudflare-speed-cli";
    rev = "v${version}";
    hash = "sha256-kXq+cz5N1UqGIZ7Y081SvZ9un3aGLFcU1faVYqG1SpU=";
  };

  doCheck = false;
  cargoHash = "sha256-bjrkl/6Gd/jJNA7g6HoRWFa6dMBEZ2PAOar97YqVkxw=";

  meta = {
    description = "CLI for internet speed test via cloudflare";
    homepage = "https://github.com/kavehtehrani/cloudflare-speed-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cloudflare-speed-cli";
  };
}
