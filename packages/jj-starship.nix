{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  libiconv,
  apple-sdk,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "jj-starship";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "dmmulroy";
    repo = "jj-starship";
    rev = "v${version}";
    hash = "sha256-FCkDSxGJAge86r5xMzr2lV0pjslS8ZQ7vBNId0VDDi0=";
  };

  cargoHash = "sha256-DtUI8DDhU1MPbP2tA/GfW4UuQcZtrUirxMeE5OZvCCE=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    zlib
  ]
  ++ lib.optionals stdenv.isDarwin [
    # Security.framework - TLS/SSL and cryptographic operations for HTTPS git
    # SystemConfiguration.framework - Network configuration (proxy, DNS)
    apple-sdk
    # libiconv - Character encoding conversion (separate from glibc on macOS)
    libiconv
  ];

  doCheck = false;

  meta = with lib; {
    description = "Unified Git/JJ Starship prompt module optimized for latency";
    homepage = "https://github.com/dmmulroy/jj-starship";
    changelog = "https://github.com/dmmulroy/jj-starship/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "jj-starship";
    platforms = platforms.unix;
  };
}
