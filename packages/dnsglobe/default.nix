{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dnsglobe";
  version = "0.5.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "514-labs";
    repo = "dnsglobe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c5H7i7ElWj4lbzDe4+l2av87HndvCHzr8QpQgcKDLGg=";
  };

  cargoHash = "sha256-1h8zBS81hNbnYyLiqyqTQRnAaiB5t0SFnqxasAPV6DQ=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Global DNS propagation checker TUI — watch a DNS record propagate across public resolvers worldwide, on a world map in your terminal";
    homepage = "https://github.com/514-labs/dnsglobe";
    changelog = "https://github.com/514-labs/dnsglobe/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dnsglobe";
  };
})
