{
  lib,
  stdenv,
  fetchPypi,
  unzip,
  autoPatchelfHook,
  versionCheckHook,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nmem-cli";
  version = "0.10.49";

  # Prebuilt Rust binary shipped as a platform wheel on PyPI (no public source
  # tree). Wheel filename uses nmem_cli; fetchPypi URL path must match that.
  src =
    let
      inherit (stdenv.hostPlatform) system;
      wheels = {
        x86_64-linux = {
          platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
          hash = "sha256-a42K0G0UM5xFjvPC/iB70TyppNScs95pWrmaeGntuy8=";
        };
        aarch64-linux = {
          platform = "manylinux_2_17_aarch64.manylinux2014_aarch64";
          hash = "sha256-g1+Yje+C8bC3V3aFm0H7+6FZeSD7A38ao5fleE+wuRY=";
        };
        x86_64-darwin = {
          platform = "macosx_10_12_x86_64";
          hash = "sha256-QZXQqFrRNMs3W2J8Veagvwh5Ty80Wd6Bsw7JZku/xfI=";
        };
        aarch64-darwin = {
          platform = "macosx_11_0_arm64";
          hash = "sha256-kN8DhUQ0A67WKDXPEbmdDoxb7/R1L6HBKJTescnOAA4=";
        };
      };
      data = wheels.${system} or (throw "Unsupported system: ${system}");
    in
    fetchPypi {
      pname = "nmem_cli";
      inherit (finalAttrs) version;
      format = "wheel";
      python = "py3";
      abi = "none";
      dist = "py3";
      inherit (data) platform hash;
    };

  nativeBuildInputs = [
    unzip
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # unzip's setup-hook does not recognise .whl
  unpackPhase = ''
    runHook preUnpack
    unzip -qq "$src"
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 nmem_cli-${finalAttrs.version}.data/scripts/nmem $out/bin/nmem
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/nmem";
  versionCheckProgramArg = "--version";

  # Vanilla nix-update only refreshes the current system's src hash and cannot
  # discover versions from files.pythonhosted.org wheel URLs. This script
  # pulls the latest PyPI release and rewrites every platform entry.
  passthru.updateScript = [
    (lib.getExe python3)
    ./update.py
  ];

  meta = {
    description = "CLI and TUI for Nowledge Mem — AI memory management";
    homepage = "https://mem.nowledge.co/docs/cli";
    downloadPage = "https://pypi.org/project/nmem-cli/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "nmem";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
