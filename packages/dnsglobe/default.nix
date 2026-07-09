{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dnsglobe";
  version = "0.3.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "514-labs";
    repo = "dnsglobe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ELZQTgq7abQZfOTZDz9hF5qbMjTUKoSrTVu5GCKWzX4=";
  };

  cargoHash = "sha256-LQTSOUopc74KMajQdGNROKwLu2XpOrwnPlE3afM3YIk=";

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
