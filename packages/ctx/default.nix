{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ctx";
  version = "0.19.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ctxrs";
    repo = "ctx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JXWkAjuI7go6HIJRZWa9X5VTH1oOtvnps6IMqQjYX0g=";
  };

  cargoHash = "sha256-iP3GAsUBy9LztlKL9UyQaVIcreUOPSwk2SWB1w8MGTk=";

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
