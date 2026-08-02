{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "launchdeck";
  version = "0.1.3";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "sderosiaux";
    repo = "launchdeck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d+XW9YzXybuYdrPIqMSdp2BMbkDxn6LX9WnODSZ+zOU=";
  };

  cargoHash = "sha256-CftTfqT0azpNR4a8qfZZQCMwefPbvptPHdb5Km96Wkc=";

  # Upstream asserts on a shell-words error substring that no longer matches.
  checkFlags = [
    "--skip=create::tests::invalid_argument_quoting_is_rejected"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unified macOS service console for launchd and Homebrew";
    homepage = "https://github.com/sderosiaux/launchdeck";
    changelog = "https://github.com/sderosiaux/launchdeck/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "launchdeck";
    # Runtime target is macOS (launchd / Homebrew services). Keep unix so
    # Linux CI can still compile and cache the derivation.
    platforms = lib.platforms.unix;
  };
})
