{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cloudflare-speed-cli";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "kavehtehrani";
    repo = "cloudflare-speed-cli";
    rev = "v${version}";
    hash = "sha256-axu4LWyqrJ11MsmQ+jHI6mGBLFBKNDjlQyc9NsMyYtw=";
  };

  doCheck = false;
  cargoHash = "sha256-eQ3AbYjWpkZjynvMr+z+aSxeZkB3r3PHcK+Xf5Xjrug=";

  meta = {
    description = "CLI for internet speed test via cloudflare";
    homepage = "https://github.com/kavehtehrani/cloudflare-speed-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cloudflare-speed-cli";
  };
}
