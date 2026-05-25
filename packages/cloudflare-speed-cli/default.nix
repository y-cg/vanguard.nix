{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cloudflare-speed-cli";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "kavehtehrani";
    repo = "cloudflare-speed-cli";
    rev = "v${version}";
    hash = "sha256-J3368ZgEopESWJK+/7OhAwHeKHVeORHkfAfOhvahuFc=";
  };

  cargoHash = "sha256-Gc0Cwpn9K9m0RSx7TTdYD5gzVvmGBIGk3BwFQD9jDq8=";

  meta = {
    description = "CLI for internet speed test via cloudflare";
    homepage = "https://github.com/kavehtehrani/cloudflare-speed-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cloudflare-speed-cli";
  };
}
