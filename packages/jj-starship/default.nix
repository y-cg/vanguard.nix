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
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "dmmulroy";
    repo = "jj-starship";
    rev = "v${version}";
    hash = "sha256-NLds7i1ZmscicaNLmkZCWmc7A+367BXxGioRd4yYof8=";
  };

  cargoHash = "sha256-i7x/y+BkKH+Xj1bU4RRe9fcteabB+4uAgJuW3x5/jv4=";

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
