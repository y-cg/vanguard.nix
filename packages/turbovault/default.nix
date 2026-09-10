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
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "Epistates";
    repo = "turbovault";
    rev = "v${version}";
    hash = "sha256-1QBdvNtJdIaajq9d/bbUSQ74fWLpZ20ROtKmNiGIezo=";
  };

  cargoHash = "sha256-ThTwGVsNp65B7CAbp7mgwy4APAXG/3TZ0JZTJRe0MDM=";

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
