{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  python3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grit";
  version = "0.5.4";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "grit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2DYQ61FNMfMYObwQ4EcEK6rID7j91BCKz/kPR7xf0Ig=";
  };

  cargoHash = "sha256-V3/V1aqv5FcaMkqxkqntlxZ90AL6J0GbRoA/MsxfSEI=";

  cargoBuildFlags = [
    "-p"
    "grit-cli"
  ];

  nativeBuildInputs = [ python3 ];

  doCheck = false;

  postInstall = ''
    rm -f $out/bin/test-httpd
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A Git implementation in Rust";
    homepage = "https://github.com/gitbutlerapp/grit";
    changelog = "https://github.com/gitbutlerapp/grit/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "grit";
    platforms = lib.platforms.unix;
  };
})
