{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  writeShellScript,
  nushell,
}:

let
  # The updater owns this data file. Keeping release facts outside the Nix
  # expression prevents an upstream metadata change from becoming a source
  # rewrite, while evaluation remains fully local and reproducible.
  release = builtins.fromJSON (builtins.readFile ./release.json);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-acp";
  version = release.version;

  src = fetchurl (
    release.sources.${stdenv.hostPlatform.system} or (throw ''
      Unsupported system: ${stdenv.hostPlatform.system}
      antigravity-acp supports: ${lib.concatStringsSep ", " (lib.attrNames release.sources)}
    '')
  );

  nativeBuildInputs = [
    makeWrapper
    unzip
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  dontConfigure = true;
  dontBuild = true;
  # Upstream ships a ~900MB PAR with debug info; stripping is not useful.
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    unzip -q $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/antigravity-acp $out/bin
    install -Dm755 agy_acp_server.par $out/libexec/antigravity-acp/agy_acp_server.par
    install -Dm755 localharness_external $out/libexec/antigravity-acp/localharness_external

    # ACP Registry (and Zed) invoke `./agy_acp_server.par` with `--uid=` on
    # Linux so the server does not try to drop privileges to group nobody.
    makeWrapper $out/libexec/antigravity-acp/agy_acp_server.par $out/bin/agy-acp-server \
      --set ANTIGRAVITY_HARNESS_PATH $out/libexec/antigravity-acp/localharness_external \
      ${lib.optionalString stdenv.hostPlatform.isLinux "--add-flags '--uid='"}

    # Keep the upstream binary name available for editor configs that expect it.
    ln -s $out/bin/agy-acp-server $out/bin/agy_acp_server.par

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/agy-acp-server --help | grep -q "AGY ACP Server"
    runHook postInstallCheck
  '';

  passthru = {
    sources = lib.mapAttrs (_: source: fetchurl source) release.sources;

    updateScript = writeShellScript "update-antigravity-acp" ''
      set -euo pipefail
      # nix-update runs this store-packaged script from the flake root. The
      # mutable metadata must remain in that checkout, never beside update.nu
      # in the store.
      export ANTIGRAVITY_ACP_RELEASE_FILE="$PWD/packages/antigravity-acp/release.json"
      export PATH="${lib.makeBinPath [ nushell ]}:$PATH"
      exec nu ${./update.nu} "$@"
    '';
  };

  meta = {
    description = "Google Antigravity ACP server for Zed and other ACP clients";
    homepage = "https://antigravity.google/docs/ide/extensions/zed";
    downloadPage = "https://github.com/agentclientprotocol/registry/tree/main/antigravity-acp";
    changelog = "https://antigravity.google/releases";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "agy-acp-server";
    platforms = lib.attrNames finalAttrs.passthru.sources;
  };
})
