{
  lib,
  stdenv,
  fetchPypi,
  unzip,
  autoPatchelfHook,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nmem-cli";
  version = "0.10.31";

  # Prebuilt Rust binary shipped as a platform wheel on PyPI (no public source
  # tree). Wheel filename uses nmem_cli; fetchPypi URL path must match that.
  src =
    let
      inherit (stdenv.hostPlatform) system;
      wheels = {
        x86_64-linux = {
          platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
          hash = "sha256-khWfvlmZUVVkbe0Oga6olCkC1bLyu2V7VGYE/8pXSjo=";
        };
        aarch64-linux = {
          platform = "manylinux_2_17_aarch64.manylinux2014_aarch64";
          hash = "sha256-EP0cELUl6Ze4hT0ti1qyDJ6ghyEx0tEyZzIpHVk0mLI=";
        };
        x86_64-darwin = {
          platform = "macosx_10_12_x86_64";
          hash = "sha256-th46H/sOtTPCeSj/ltCBz+garNDWTnggZ3UelxNOvo8=";
        };
        aarch64-darwin = {
          platform = "macosx_11_0_arm64";
          hash = "sha256-w0hPeYlib7AeBC5FdD1EAG7858fvS4PNQTT7vSd5zjs=";
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
