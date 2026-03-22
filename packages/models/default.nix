{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "models";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "arimxyer";
    repo = "models";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M1wBqE6+OXSdNyk6g3UnaARGhZkI4snY8BOIiLXHEss=";
  };

  cargoHash = "sha256-VkMj64SHtYZTP8l+Qu1J47iSgh9Ib0dULcIs7AQW52Q=";
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
