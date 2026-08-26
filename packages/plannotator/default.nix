{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  glib,
  libsecret,
  stdenv,
}:

let
  version = "0.27.8";
  sources = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-E71OrlkWwRksP3H9TIcigp1wdueBhQ/WoO8v/G8WzGs=";
    };
    x86_64-darwin = {
      arch = "darwin-x64";
      hash = "sha256-JTPHhCM9pECYhEtwcHq29FOSClRDqdvZW7+ONJrInhs=";
    };
    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-tXNU/Yy5ytasCS8IaY//ZZw2xGkNId11XDyANu7qLxU=";
    };
    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-owcUKEOYRvwqtoBGfrYZwsipAidcKKepZxk69XU7F9Y=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "plannotator: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${source.arch}";
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
