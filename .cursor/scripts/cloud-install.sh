#!/usr/bin/env bash
# Cursor Cloud install/update hook for this Nix flake repo.
# Must be idempotent: may run on a fresh VM or a partially cached snapshot.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"

# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || \
  export PATH="/nix/var/nix/profiles/default/bin:${PATH}"
export PATH="/nix/var/nix/profiles/default/bin:${HOME}/.nix-profile/bin:${PATH}"

"${ROOT}/.cursor/scripts/ensure-nix-daemon.sh"
devenv update
