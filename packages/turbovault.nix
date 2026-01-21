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
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "Epistates";
    repo = "turbovault";
    rev = "v${version}";
    hash = "sha256-hyiXGQON1rCAMuuFARaeo/uldobPDylfBmZFMLHV+2w=";
  };

  cargoHash = "sha256-5MwiNce8Jk2HahvtmY2E1xyuqIpKQFioAko8YUggIZc=";

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
