{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustfs-client";
  version = "0.1.36";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rustfs";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KKidgJMijvcxp5Ek0gknEdr5paHyarXYAB75e7feKEQ=";
  };

  cargoHash = "sha256-CmPMjJc/yyn0csYsKJawzfc+Rkz2gYWCmJVkgJLz/pQ=";

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
