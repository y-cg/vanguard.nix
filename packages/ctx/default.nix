{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ctx";
  version = "0.17.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ctxrs";
    repo = "ctx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D2mv5KulLb3Q9THgoEaJgKh1A0n4cWA0d88is9hUel4=";
  };

  cargoHash = "sha256-DNTvMqXJOUiroCRfhCKNJ3/McJC2MROPeOdH59qqYeE=";

  cargoBuildFlags = [
    "-p"
    "ctx"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Search the coding agent history already on your machine";
    homepage = "https://github.com/ctxrs/ctx";
    changelog = "https://github.com/ctxrs/ctx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ctx";
  };
})
