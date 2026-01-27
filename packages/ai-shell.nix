{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.12";
in
buildNpmPackage {
  pname = "ai-shell";
  inherit version;

  src = fetchFromGitHub {
    owner = "BuilderIO";
    repo = "ai-shell";
    rev = "v${version}";
    hash = "sha256-zRJF1yruQdsocAEWfEQS2eZOBg0a63GelkPyDcin2qM=";
  };

  npmDepsHash = "sha256-NJHWm0iihZuTig22Amh2gI1uDEGmREQtSS+9tdr6AFk=";

  meta = with lib; {
    description = "CLI that converts natural language to shell commands";
    homepage = "https://github.com/BuilderIO/ai-shell";
    license = licenses.mit;
    mainProgram = "ai";
  };
}
