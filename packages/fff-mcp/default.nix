{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  cmake,
  openssl,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fff-mcp";
  version = "0.10.6";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "dmtrKovalenko";
    repo = "fff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IR8w57VPiCerh8tEUhzNjd2A7BMY1Dvs0Yl0rIIoj1E=";
  };

  cargoHash = "sha256-mt5T9Cs174pc1CtrPZE6hwYZ3eSaGhCRL94trcoZn4Q=";

  # Default features use the pure-Rust ripgrep walker. Do not enable `zlob`,
  # which needs a Zig toolchain and would pull extra flake inputs.
  cargoBuildFlags = [
    "-p"
    "fff-mcp"
  ];

  # Virtual workspace: install the MCP crate instead of the repo root.
  cargoInstallFlags = [
    "--path"
    "crates/fff-mcp"
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    openssl
    zlib
  ];

  # cmake is only needed by vendored libgit2; skip the CMake configure hook.
  dontUseCmakeConfigure = true;

  doCheck = false;

  postInstall = ''
    find "$out/bin" -mindepth 1 -maxdepth 1 -type f ! -name fff-mcp -delete
  '';

  # Nightly GitHub prereleases crowd out releases.atom. The update workflow
  # passes --use-github-releases for this package (see package-policy.toml).
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast file search toolkit for AI agents (MCP server)";
    homepage = "https://github.com/dmtrKovalenko/fff";
    changelog = "https://github.com/dmtrKovalenko/fff/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "fff-mcp";
  };
})
