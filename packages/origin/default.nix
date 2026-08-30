{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
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
  pname = "origin";
  version = release.version;

  src = fetchurl (
    release.sources.${stdenv.hostPlatform.system} or (throw ''
      Unsupported system: ${stdenv.hostPlatform.system}
      origin supports: ${lib.concatStringsSep ", " (lib.attrNames release.sources)}
    '')
  );

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Archive ships a legacy `co` hard link; public installs expose only `origin`.
    install -Dm755 origin $out/bin/origin

    runHook postInstall
  '';

  # Upstream manifest versions are build stamps; `origin --version` reports semver.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/origin --version | grep -q .
    runHook postInstallCheck
  '';

  passthru = {
    # Artifacts retain the legacy co/ prefix even though the public CLI is
    # named origin. fetchurl keeps every downloaded archive content-addressed.
    sources = lib.mapAttrs (_: source: fetchurl source) release.sources;

    updateScript = writeShellScript "update-origin" ''
      set -euo pipefail
      # nix-update runs this store-packaged script from the flake root. The
      # mutable metadata must remain in that checkout, never beside update.nu
      # in the store.
      export ORIGIN_RELEASE_FILE="$PWD/packages/origin/release.json"
      export PATH="${lib.makeBinPath [ nushell ]}:$PATH"
      if [ -n "''${1:-}" ]; then
        exec nu ${./update.nu} "$1"
      fi
      exec nu ${./update.nu}
    '';
  };

  meta = {
    description = "Cursor Origin CLI for Cursor-hosted git repositories";
    homepage = "https://cursor.com/";
    changelog = "https://www.cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "origin";
    platforms = lib.attrNames finalAttrs.passthru.sources;
  };
})
