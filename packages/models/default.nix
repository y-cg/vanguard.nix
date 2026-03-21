{
  lib,
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

  meta = {
    description = "TUI and CLI for browsing AI models, benchmarks, and coding agents";
    homepage = "https://github.com/arimxyer/models";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "models";
  };
})
