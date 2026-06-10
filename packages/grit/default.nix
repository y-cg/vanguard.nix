{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  python3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grit";
  version = "0.3.99";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "grit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SmCpobE3VKhLfvFplLDTRQr2ExrBFUu+NMeLUjcQ8nI=";
  };

  cargoHash = "sha256-evsBVN4+tS4o/YrTbI2+sKmaeJuKyz6a4yL7Lvp0Zm8=";

  cargoBuildFlags = [
    "-p"
    "grit-cli"
  ];

  nativeBuildInputs = [ python3 ];

  doCheck = false;

  postInstall = ''
    rm $out/bin/test-httpd
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
