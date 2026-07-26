#!/usr/bin/env bash
# Cursor Cloud install/update hook for this Nix flake repo.
# Must be idempotent: may run on a fresh VM or a partially cached snapshot.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"

install_nix_if_missing() {
  if [[ -x /nix/var/nix/profiles/default/bin/nix ]]; then
    echo "[cloud-install] nix already installed"
    return 0
  fi

  echo "[cloud-install] installing Determinate Nix (non-systemd)"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install linux --no-confirm --init none
}

ensure_nix_profile() {
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || \
    export PATH="/nix/var/nix/profiles/default/bin:${PATH}"
  export PATH="/nix/var/nix/profiles/default/bin:${HOME}/.nix-profile/bin:${PATH}"
}

install_devenv_if_missing() {
  if command -v devenv >/dev/null 2>&1; then
    echo "[cloud-install] devenv already installed"
    return 0
  fi

  echo "[cloud-install] installing devenv"
  nix profile install github:cachix/devenv/v2.1.2 -L --accept-flake-config
}

install_nix_if_missing
ensure_nix_profile
"${ROOT}/.cursor/scripts/configure-nix-substituters.sh"
"${ROOT}/.cursor/scripts/ensure-nix-daemon.sh"
install_devenv_if_missing
devenv update
