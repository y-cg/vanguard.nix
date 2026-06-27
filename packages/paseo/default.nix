{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  python3,
  makeWrapper,
  libuv,
}:

let
  version = "0.1.101";
  fetchedSrc = fetchFromGitHub {
    owner = "getpaseo";
    repo = "paseo";
    tag = "v${version}";
    hash = "sha256-5NZS8mcsUtOn/Id8ZDykyghPbUlNNSw1Hmx23ZvuxPI=";
  };
in
buildNpmPackage rec {
  pname = "paseo";
  inherit version;

  src = lib.cleanSourceWith {
    src = fetchedSrc;
    filter =
      path: type:
      let
        baseName = baseNameOf path;
        relPath = lib.removePrefix (toString fetchedSrc) path;
      in
      !(lib.hasPrefix "/packages/app/src" relPath)
      && !(lib.hasPrefix "/packages/app/assets" relPath)
      && !(lib.hasPrefix "/packages/app/android" relPath)
      && !(lib.hasPrefix "/packages/app/ios" relPath)
      && !(lib.hasPrefix "/packages/website/src" relPath)
      && !(lib.hasPrefix "/packages/website/public" relPath)
      && !(lib.hasPrefix "/packages/desktop/src" relPath)
      && !(lib.hasPrefix "/packages/desktop/src-tauri" relPath)
      && !(lib.hasSuffix ".test.ts" baseName)
      && !(lib.hasSuffix ".e2e.test.ts" baseName)
      && baseName != "node_modules"
      && baseName != ".git"
      && baseName != ".paseo"
      && baseName != ".DS_Store";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-7Xru5RdmXKX9U5tv4jn1wXChw3kfBuSnb2oRA+7HR7Q=";

  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    python3
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libuv
  ];

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    npm rebuild node-pty

    npm run build:server

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/paseo
    node scripts/trace-daemon.mjs > daemon-files.txt

    while IFS= read -r path; do
      [ -z "$path" ] && continue
      mkdir -p "$out/lib/paseo/$(dirname "$path")"
      cp -a "$path" "$out/lib/paseo/$path"
    done < daemon-files.txt

    cp package.json $out/lib/paseo/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/paseo-server \
      --add-flags "$out/lib/paseo/packages/server/dist/scripts/supervisor-entrypoint.js" \
      --set NODE_ENV production

    makeWrapper ${nodejs}/bin/node $out/bin/paseo \
      --add-flags "$out/lib/paseo/packages/cli/dist/index.js" \
      --set NODE_PATH "$out/lib/paseo/node_modules"

    runHook postInstall
  '';

  meta = {
    description = "Orchestrate multiple coding agents from desktop and mobile";
    homepage = "https://github.com/getpaseo/paseo";
    changelog = "https://github.com/getpaseo/paseo/releases/tag/v${version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "paseo";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
