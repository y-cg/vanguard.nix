{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  python3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grit";
  version = "0.5.12";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "grit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zun+zefxCvNaTs2l7SoVG/Wmc2E9QCn/h4bzgSNuf1Y=";
  };

  cargoHash = "sha256-wsZIUd7FN/Zl4XA3zKeYLil8sgIAtmINhBqBpAv/RjE=";

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
