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
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "dmmulroy";
    repo = "jj-starship";
    rev = "v${version}";
    hash = "sha256-YfcFlJsPCRfqhN+3JUWE77c+eHIp5RAu2rq/JhSxCec=";
  };

  cargoHash = "sha256-XMz6b63raPkgmUzB6L3tOYPxTenytmGWOQrs+ikcSts=";

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
