#!/usr/bin/env bash
# Ensure Determinate Nix daemon is running on Cursor Cloud (non-systemd) pods.
#
# These VMs boot with tini/pod-daemon instead of systemd, so nix-daemon.service
# never starts. devenv/nix then fail with:
#   cannot connect to socket at '/nix/var/nix/daemon-socket/socket': Connection refused
#
# Idempotent: safe to run from install and start hooks.

set -euo pipefail

NIX_BIN="${NIX_BIN:-/nix/var/nix/profiles/default/bin}"
DETERMINATE_NIXD="${DETERMINATE_NIXD:-/usr/local/bin/determinate-nixd}"
SOCKET_PATH="${NIX_DAEMON_SOCKET:-/nix/var/nix/daemon-socket/socket}"
LOG_PATH="${DETERMINATE_NIXD_LOG:-/tmp/determinate-nixd.log}"
MAX_WAIT_ATTEMPTS="${NIX_DAEMON_WAIT_ATTEMPTS:-60}"

export PATH="${NIX_BIN}:${HOME}/.nix-profile/bin:${PATH}"

# Load nix profile helpers when available (no-op if missing).
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || true

daemon_ready() {
  nix store info --store daemon >/dev/null 2>&1
}

if daemon_ready; then
  echo "[ensure-nix-daemon] nix daemon already reachable"
  exit 0
fi

if [[ ! -x "${DETERMINATE_NIXD}" ]]; then
  echo "[ensure-nix-daemon] missing executable: ${DETERMINATE_NIXD}" >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "[ensure-nix-daemon] sudo is required to start determinate-nixd" >&2
  exit 1
fi

echo "[ensure-nix-daemon] starting determinate-nixd (non-systemd boot)"
sudo mkdir -p /nix/var/determinate /nix/var/nix/daemon-socket

# Snapshot images often leave a stale socket inode with nothing listening.
if [[ -e "${SOCKET_PATH}" ]] && ! daemon_ready; then
  echo "[ensure-nix-daemon] removing stale socket: ${SOCKET_PATH}"
  sudo rm -f "${SOCKET_PATH}"
fi

# Start detached so install/start scripts can exit. Redirect to a log for debugging.
sudo "${DETERMINATE_NIXD}" daemon >>"${LOG_PATH}" 2>&1 &

for ((i = 1; i <= MAX_WAIT_ATTEMPTS; i++)); do
  if daemon_ready; then
    echo "[ensure-nix-daemon] nix daemon ready after ${i} attempt(s)"
    exit 0
  fi
  sleep 0.25
done

echo "[ensure-nix-daemon] timed out waiting for nix daemon at ${SOCKET_PATH}" >&2
if [[ -f "${LOG_PATH}" ]]; then
  echo "[ensure-nix-daemon] last log lines:" >&2
  tail -n 50 "${LOG_PATH}" >&2 || true
fi
exit 1
