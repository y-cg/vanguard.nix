{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dnsglobe";
  version = "0.4.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "514-labs";
    repo = "dnsglobe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WWjBjRyORn46M4gmKGRwbWh8Eu8VdVsaRoN1n4sRiFA=";
  };

  cargoHash = "sha256-ugsTrYPFkLl0W1f9kXT7xGvB6Ro+j/kk3GMufgtFBak=";

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
