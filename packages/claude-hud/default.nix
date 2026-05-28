{
  lib,
  fetchFromGitHub,
  bun,
  writeShellApplication,
}:

let
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "jarrodwatts";
    repo = "claude-hud";
    rev = "bdc8c654439e37ddd241928ab8607949a8568173";
    hash = "sha256-X+2NF5m/hVUoi9FTDqKv6YEYUk/P8uI4fyodgx31Lk4=";
  };
in
writeShellApplication {
  name = "claude-hud";

  # The CLI reads JSON from stdin and writes to stdout
  # It's a statusline HUD for Claude Code
  runtimeInputs = [ bun ];

  text = ''
    exec ${bun}/bin/bun run ${src}/src/index.ts "$@"
  '';

  meta = with lib; {
    description = "Real-time statusline HUD for Claude Code";
    homepage = "https://github.com/jarrodwatts/claude-hud";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
