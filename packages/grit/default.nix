{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  python3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grit";
  version = "0.5.3";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "grit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1vGCaLOl8NyRCdQ8oo7rOe9WoQUlp924g3HgTs8SRUY=";
  };

  cargoHash = "sha256-59qoLm5IGT4wzX49Ue5FDi+hTYb39rrXLSp5MhDt4rU=";

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
