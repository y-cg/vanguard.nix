{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "models";
  version = "0.11.52";

  src = fetchFromGitHub {
    owner = "riyamira";
    repo = "models";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RFyJtZ+W6DV5eBU28Lv8vVAm90yHQW+VCvnph3QlRuk=";
  };

  cargoHash = "sha256-RDOnHAI0jp78gX3ZSkCAaW+T5PuP6UAM6QA6908In2s=";
  doCheck = false;

  nativeBuildInputs = with pkgs; [
    makeWrapper
    installShellFiles
  ];

  postInstall =
    let
      models = "$out/bin/models";
    in
    ''
      wrapProgram ${models} \
        --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

      installShellCompletion --cmd models \
            --bash <(${models} completions bash) \
            --fish <(${models} completions fish) \
            --zsh <(${models} completions zsh)
    '';

  meta = {
    description = "TUI and CLI for browsing AI models, benchmarks, and coding agents";
    homepage = "https://github.com/arimxyer/models";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "models";
  };
})
