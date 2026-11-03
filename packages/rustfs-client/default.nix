{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustfs-client";
  version = "0.1.37";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rustfs";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5qBjTNnfVv4fsFXFkvkJyuZ0lmE9ZE7bEmuAmcg1388=";
  };

  cargoHash = "sha256-+iaR7BwlWeyiz9L2b2vsQelMTPaux4LDbXDuLGAR4Ng=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd rc \
      --bash <($out/bin/rc completions bash) \
      --fish <($out/bin/rc completions fish) \
      --zsh <($out/bin/rc completions zsh)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust S3 CLI client for S3-compatible object storage";
    homepage = "https://github.com/rustfs/cli";
    changelog = "https://github.com/rustfs/cli/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "rc";
  };
})
