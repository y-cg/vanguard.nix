{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ctx";
  version = "0.24.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ctxrs";
    repo = "ctx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ctlDglcgUA34qxsOGxLktUS6cLUK0wMcnb3HrHjyz3Y=";
  };

  cargoHash = "sha256-868tSR3GjN/WvYHG738iBW0VwxnhndUxZ7fSo7OsFzo=";

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
