{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  cmake,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fff-mcp";
  version = "0.10.5";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "dmtrKovalenko";
    repo = "fff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-STWQVXZCTlXteuojY2L8dN5Hy+gcUYqn/FqxV4YbieA=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  # Default features use the pure-Rust ripgrep walker. Do not enable `zlob`,
  # which needs a Zig toolchain and would pull extra flake inputs.
  cargoBuildFlags = [
    "-p"
    "fff-mcp"
    "--bin"
    "fff-mcp"
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [ openssl ];

  doCheck = false;

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
