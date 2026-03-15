{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "models";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "arimxyer";
    repo = "models";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I8dPV6Nbg62UmJcBQSpuHwGY/3b0jt1vStaS5PYdS6Y=";
  };

  cargoHash = "sha256-b2QlNecTvV09t7qEx0R8MuuqlCmXMra2bPDK/JPLO3o=";
  doCheck = false;

  meta = {
    description = "TUI and CLI for browsing AI models, benchmarks, and coding agents";
    homepage = "https://github.com/arimxyer/models";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "models";
  };
})
