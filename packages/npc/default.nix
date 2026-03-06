{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "npc";
  version = "0-unstable-2026-03-05";

  src = fetchFromGitHub {
    owner = "samestep";
    repo = "npc";
    rev = "03bd2e6bc857898f51a855999e2d93da18536a53";
    hash = "sha256-yj5HagyA+2Hllq3VqROIB2B/+Pw1G2QTY9tRKf3hadg=";
  };

  cargoHash = "sha256-KFm7IAQNfPvPgKRaTQL630sk4Eukrwm6l/k5M+yiKvg=";

  meta = {
    description = "Nixpkgs channel history CLI";
    homepage = "https://github.com/samestep/npc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "npc";
  };
})
