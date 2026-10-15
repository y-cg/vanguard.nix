# Prebuilt GitHub-release binaries. nix-update only rewrites the host
# system's `src` hash, so passthru.updateScript prefetches every platform
# asset and patches the hashes below.
{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  glib,
  libsecret,
  stdenv,
  writeShellScript,
  nushell,
}:

let
  version = "0.28.19";
  sources = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-8mXOye+pL9+IE80UniGYwbmh7pkCe0XW8lQmdUZ6rCM=";
    };
    x86_64-darwin = {
      arch = "darwin-x64";
      hash = "sha256-LEJR8Ho9r+WWuL6SoAWJ4K5sEZGmDOYMK7VgxeKPvpE=";
    };
    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-XMi9PAgUvidyFxumVAtyy9MIEtE0uQ14TAJi0BBIa+Q=";
    };
    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-beRgXDeCJE6a5xLn7E6dPhLmSHhjpMphWRbTLKE9l3c=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system} or (throw ''
      plannotator: unsupported platform ${stdenv.hostPlatform.system}
    '');
  srcUrl =
    systemSource:
    "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${systemSource.arch}";
in
stdenvNoCC.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = srcUrl source;
    inherit (source) hash;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Prebuilt binary embeds a payload that strip corrupts; --version then
  # reports a wrong string and installCheck fails on Linux.
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    glib
    libsecret
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/plannotator
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/plannotator --version | grep -q "${version}"
    runHook postInstallCheck
  '';

  passthru = {
    sources = lib.mapAttrs (
      _: systemSource:
      fetchurl {
        url = srcUrl systemSource;
        inherit (systemSource) hash;
      }
    ) sources;

    updateScript = writeShellScript "update-plannotator" ''
      set -euo pipefail
      # nix-update runs this store-packaged script from the flake root. The
      # Nix expression to patch lives in that checkout, never beside update.nu
      # in the store.
      export PLANNOTATOR_NIX_FILE="$PWD/packages/plannotator/default.nix"
      export PATH="${lib.makeBinPath [ nushell ]}:$PATH"
      if [ -n "''${1:-}" ]; then
        exec nu ${./update.nu} "$1"
      fi
      exec nu ${./update.nu}
    '';
  };

  meta = {
    description = "Annotate and review coding agent plans and code diffs visually";
    homepage = "https://plannotator.ai";
    changelog = "https://github.com/backnotprop/plannotator/releases/tag/v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "plannotator";
    platforms = lib.attrNames sources;
  };
}
