{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flyline";
  version = "1.2.3";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "HalFrgrd";
    repo = "flyline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1or9LdGOAAnfaBuy7de6ZD3aqEqkTUAsUKnXH1LaRqM=";
  };

  cargoHash = "sha256-JCA7a/Sl+E78Tqwg5xLLoUmhQKQkwGmxf2b6iNU/vts=";

  nativeBuildInputs = [ git ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    libFile=$(find target -name 'libflyline*' -type f | head -n1)
    if [ -z "$libFile" ]; then
      echo "Could not find libflyline artifact"
      find target -type f \( -name '*.so' -o -name '*.dylib' \) || true
      exit 1
    fi

    mkdir -p $out/lib/bash
    cp "$libFile" "$out/lib/bash/libflyline${stdenv.hostPlatform.extensions.sharedLibrary}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bash plugin for modern command line editing with syntax highlighting, fuzzy history, and rich prompts";
    homepage = "https://github.com/HalFrgrd/flyline";
    changelog = "https://github.com/HalFrgrd/flyline/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      gpl3Only
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
