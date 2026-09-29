{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "turbovault";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "Epistates";
    repo = "turbovault";
    rev = "v${version}";
    hash = "sha256-eMKG+XFWR6fV/Dd8OclryverhsfxrLDINduZZE1chRg=";
  };

  cargoHash = "sha256-BbSWUA/14ku4wztdFo8tDzZQYLFw255sNCN8qdzFjRI=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.isDarwin [ ];

  buildNoDefaultFeatures = false;
  buildFeatures = [ "full" ];

  doCheck = false;

  meta = with lib; {
    description = "LLM-optimized Obsidian vault MCP server with advanced editing, search, and graph analysis";
    homepage = "https://github.com/Epistates/turbovault";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "turbovault";
  };
}
