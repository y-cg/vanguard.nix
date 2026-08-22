# Official SEA distribution of Raft Computer (`curl …/install.sh | sh`).
# Binaries and photon wasm come from https://cdn.raft.build/computer.
# Refresh hashes with packages/raft-computer/update.sh (also wired as
# passthru.updateScript for `nix-update --flake raft-computer -u`).
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  gzip,
  makeWrapper,
  autoPatchelfHook,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

let
  manifest = lib.importJSON ./manifest.json;
  baseUrl = "https://cdn.raft.build/computer";
  platformKey = "${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}";
  target =
    manifest.targets.${platformKey} or (throw "raft-computer: unsupported platform ${platformKey}");
  photonWasm = fetchurl {
    url = "${baseUrl}/${manifest.version}/${manifest.photonWasm.file}";
    inherit (manifest.photonWasm) hash;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "raft-computer";
  inherit (manifest) version;

  src = fetchurl {
    url = "${baseUrl}/${finalAttrs.version}/${target.file}";
    inherit (target) hash;
  };

  dontUnpack = true;
  dontBuild = true;
  # SEA binary ships with debug_info / too many notes; stripping breaks it.
  dontStrip = true;

  nativeBuildInputs = [
    gzip
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isElf [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/raft-computer $out/bin
    gzip -cd "$src" > $out/libexec/raft-computer/raft-computer
    chmod +x $out/libexec/raft-computer/raft-computer
    install -Dm644 ${photonWasm} $out/libexec/raft-computer/photon_rs_bg.wasm
    # photon-node loads photon_rs_bg.wasm from dirname(execPath) / argv[0].
    ln -s ../libexec/raft-computer/photon_rs_bg.wasm $out/bin/photon_rs_bg.wasm

    makeWrapper $out/libexec/raft-computer/raft-computer $out/bin/raft-computer \
      --set DISABLE_AUTOUPDATER 1 \
      --run ${lib.escapeShellArg ''
        if [ "''${1-}" = upgrade ]; then
          echo "raft-computer: self-upgrade is disabled in the Nix package; bump packages/raft-computer via the update script" >&2
          exit 1
        fi
      ''}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Raft Computer CLI (prebuilt Node SEA binary)";
    homepage = "https://raft.build";
    downloadPage = "https://cdn.raft.build/computer";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "raft-computer";
  };
})
