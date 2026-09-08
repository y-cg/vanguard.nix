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

buildNpmPackage (finalAttrs: {
  pname = "paseo";
  version = "0.1.101";

  # Keep fetchFromGitHub directly in `src` so nix-update can discover the
  # repository, tag, and hash. Source pruning happens in postPatch instead.
  src = fetchFromGitHub {
    owner = "getpaseo";
    repo = "paseo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5NZS8mcsUtOn/Id8ZDykyghPbUlNNSw1Hmx23ZvuxPI=";
  };

  postPatch = ''
    rm -rf \
      packages/app/src \
      packages/app/assets \
      packages/app/android \
      packages/app/ios \
      packages/website/src \
      packages/website/public \
      packages/desktop/src \
      packages/desktop/src-tauri
    find . -type f \( -name '*.test.ts' -o -name '*.e2e.test.ts' \) -delete
    rm -rf .paseo
  '';

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
    makeWrapper ${finalAttrs.nodejs}/bin/node $out/bin/paseo-server \
      --add-flags "$out/lib/paseo/packages/server/dist/scripts/supervisor-entrypoint.js" \
      --set NODE_ENV production

    makeWrapper ${finalAttrs.nodejs}/bin/node $out/bin/paseo \
      --add-flags "$out/lib/paseo/packages/cli/dist/index.js" \
      --set NODE_PATH "$out/lib/paseo/node_modules"

    runHook postInstall
  '';

  meta = {
    description = "Orchestrate multiple coding agents from desktop and mobile";
    homepage = "https://github.com/getpaseo/paseo";
    changelog = "https://github.com/getpaseo/paseo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "paseo";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
