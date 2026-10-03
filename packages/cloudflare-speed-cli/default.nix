{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cloudflare-speed-cli";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "kavehtehrani";
    repo = "cloudflare-speed-cli";
    rev = "v${version}";
    hash = "sha256-a8iDRuWZ5Stpt/jCZ1tZ5L2N+dju5jKSNRwgCSDnFJU=";
  };

  doCheck = false;
  cargoHash = "sha256-qEDein5Jn83/qKcNU5jPSVC0+eMmOQqQn6RdfSq56QY=";

  meta = {
    description = "CLI for internet speed test via cloudflare";
    homepage = "https://github.com/kavehtehrani/cloudflare-speed-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cloudflare-speed-cli";
  };
}
