{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "models";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "reyamira";
    repo = "models";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p1GXQhqeQUk+OuyfdP2ftCkfQJuAqt+DHlCN2sWNNfY=";
  };

  cargoHash = "sha256-3fnb3hwUBK1LkjY1JsuSzswBpP81IYXd/tXMYVXMCv4=";
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
