#!/usr/bin/env bash
# Configure Cachix substituters for faster devenv/nix profile installs on Cloud VMs.
# Idempotent: only writes /etc/nix/nix.custom.conf when required keys are missing.

set -euo pipefail

NIX_CUSTOM_CONF="${NIX_CUSTOM_CONF:-/etc/nix/nix.custom.conf}"
TRUSTED_USER="${NIX_TRUSTED_USER:-ubuntu}"

DEVENV_SUBSTITUTER="https://devenv.cachix.org"
CACHIX_SUBSTITUTER="https://cachix.cachix.org"
DEVENV_KEY="devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
CACHIX_KEY="cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="

if ! command -v sudo >/dev/null 2>&1; then
  echo "[configure-nix-substituters] sudo is required" >&2
  exit 1
fi

sudo mkdir -p /etc/nix

if [[ -f "${NIX_CUSTOM_CONF}" ]] \
  && grep -qF "${DEVENV_SUBSTITUTER}" "${NIX_CUSTOM_CONF}" \
  && grep -qF "${CACHIX_SUBSTITUTER}" "${NIX_CUSTOM_CONF}" \
  && grep -qF "${DEVENV_KEY}" "${NIX_CUSTOM_CONF}" \
  && grep -qF "${CACHIX_KEY}" "${NIX_CUSTOM_CONF}"; then
  echo "[configure-nix-substituters] ${NIX_CUSTOM_CONF} already configured"
  exit 0
fi

echo "[configure-nix-substituters] writing ${NIX_CUSTOM_CONF}"
sudo tee "${NIX_CUSTOM_CONF}" >/dev/null <<EOF
trusted-users = root ${TRUSTED_USER}
extra-substituters = ${DEVENV_SUBSTITUTER} ${CACHIX_SUBSTITUTER}
extra-trusted-public-keys = ${DEVENV_KEY} ${CACHIX_KEY}
EOF

if command -v sudo >/dev/null 2>&1 && [[ -x /usr/local/bin/determinate-nixd ]]; then
  echo "[configure-nix-substituters] restarting determinate-nixd to load new config"
  sudo pkill -x determinate-nixd 2>/dev/null || true
  sleep 0.5
fi
