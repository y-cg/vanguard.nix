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
  pname = "jj-ryu";
  version = "0.0.1-alpha.12";

  src = fetchFromGitHub {
    owner = "dmmulroy";
    repo = "jj-ryu";
    rev = "v${version}";
    hash = "sha256-2hJSd78LDl1Hrh+WA6NHxKQ1pYnk0eir/wNm6aa+dPY=";
  };

  cargoHash = "sha256-+bvAeV3Xplh5EqpaCmhJbhzZqbX4dcezvhxbwnTZraw=";

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
    description = "Stacked PRs for Jujutsu. Push bookmark stacks to GitHub and GitLab as chained pull requests.";
    homepage = "https://github.com/dmmulroy/jj-ryu";
    changelog = "https://github.com/dmmulroy/jj-ryu/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "ryu";
    platforms = platforms.unix;
  };
}
