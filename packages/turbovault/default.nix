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
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "Epistates";
    repo = "turbovault";
    rev = "v${version}";
    hash = "sha256-RDeMA4330VUms/JDGhM3r/pVrEp5q1Aj6U2l8SF6Fjs=";
  };

  cargoHash = "sha256-QtEx6wF1mAKKzrH9UE7Z3RDxfEUOLI0eqN8TQXiLvQs=";

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
