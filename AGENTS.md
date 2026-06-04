# AGENTS.md

## Cursor Cloud specific instructions

This repository is a **Nix flake** that packages third-party CLI tools. There is no Node/Python app server to run; development means building flake outputs and using the devenv shell for helper scripts.

### Services

| Component | Required? | Notes |
|-----------|-----------|--------|
| **Nix daemon** | Yes | Determinate Nix is installed at `/nix`. New shells should load `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` (also appended to `~/.bashrc`). |
| **devenv** | Recommended | Installed via `nix profile install github:cachix/devenv/v2.1.2 -L --accept-flake-config`. Binary is on `$HOME/.nix-profile/bin`. |
| **direnv** | Optional | `.envrc` runs `use devenv`; install system `direnv` and run `direnv allow` if you want auto-loading. |
| **Long-running servers** | No | Nothing listens on a port for local dev. |

### Standard commands

See `.github/workflows/ci.yml` for the canonical CI loop.

- **Enter dev shell:** `devenv shell` (from repo root)
- **List package names:** `devenv shell -- list-pkgs x86_64-linux` — note: on Nix 2.34+ `nix flake show --json` uses the `inventory` schema; if `list-pkgs` returns `[]`, enumerate packages from `packages/default.nix` or run `nix flake show` interactively.
- **Build one package:** `nix build .#<name>` then run `./result/bin/<program>`
- **Format Nix:** `devenv shell -- nixfmt --check flake.nix devenv.nix packages/` (or `nix shell nixpkgs#nixfmt-rfc-style -c nixfmt --check …`)
- **CI-equivalent builds:** loop `nix build ".#$pkg"` for each attr in `packages/default.nix`

### Cachix / substituters

devenv and CI expect substitutes from `https://devenv.cachix.org` and `https://cachix.cachix.org`. Cloud VMs should have `trusted-users` include your dev user (e.g. `ubuntu`) in `/etc/nix/nix.custom.conf` plus the `extra-substituters` / `extra-trusted-public-keys` from the devenv flake docs. Without this, `nix profile install` for devenv may compile from source for a long time.

### Gotchas

- Parallel `nix profile add` / `nix shell` invocations against devenv can contend on the Nix eval cache SQLite DB; run one install at a time.
- After changing `/etc/nix/nix.custom.conf`, restart `nix-daemon` before heavy builds.
- Rust package builds run `cargo test` in `checkPhase` (e.g. `bttf`); full CI of all packages can take a long time on a cold cache.
