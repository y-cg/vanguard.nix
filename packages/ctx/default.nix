{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  onnxruntime,
  stdenv,
  makeWrapper,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ctx";
  version = "0.25.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ctxrs";
    repo = "ctx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BaZvBlRE8PkUgacWDoNhR14YoenfKKKAoCZQUrv6TQk=";
  };

  cargoHash = "sha256-aOd7zN8U2w/nkoTxUUDrllngtUWZ/3KhGYIAJDa5F5w=";

  cargoBuildFlags = [
    "-p"
    "ctx"
  ];

  # v0.24+ pulls fastembed with ort-download-binaries on Linux x86_64, which
  # tries to fetch ONNX Runtime during the build. Point ort-sys at nixpkgs instead.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isx86_64 [ makeWrapper ];
  buildInputs = lib.optionals stdenv.hostPlatform.isx86_64 [ onnxruntime ];

  preBuild = lib.optionalString stdenv.hostPlatform.isx86_64 ''
    export ORT_LIB_LOCATION="${onnxruntime}/lib"
    export ORT_PREFER_DYNAMIC_LINK=1
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isx86_64 ''
    wrapProgram $out/bin/ctx \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ onnxruntime ]}"
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Search the coding agent history already on your machine";
    homepage = "https://github.com/ctxrs/ctx";
    changelog = "https://github.com/ctxrs/ctx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ctx";
  };
})
