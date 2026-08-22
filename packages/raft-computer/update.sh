#!/usr/bin/env bash
# Refresh packages/raft-computer/manifest.json from the public CDN.
#
# nix-update --use-update-script runs this with cwd = flake root (even when
# BASH_SOURCE is a Nix store copy). Direct invocation from the package
# directory also works.
set -euo pipefail

supported_targets=(
  darwin-arm64
  darwin-x64
  linux-arm64
  linux-x64
)

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${script_dir}/default.nix" && -w "${script_dir}" ]]; then
  pkg_dir="${script_dir}"
elif [[ -f packages/raft-computer/default.nix ]]; then
  pkg_dir="$(cd packages/raft-computer && pwd)"
else
  echo "update.sh: cannot find a writable packages/raft-computer directory" >&2
  echo "run from the repo root, or invoke packages/raft-computer/update.sh directly" >&2
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "update.sh: nix is required to convert sha256 hashes to SRI" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "update.sh: jq is required to rewrite manifest.json" >&2
  exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "update.sh: curl is required to fetch the CDN manifest" >&2
  exit 1
fi

cdn="${RAFT_COMPUTER_RELEASE_BASE:-https://cdn.raft.build/computer}"
raw="$(mktemp)"
trap 'rm -f "${raw}"' EXIT
curl -fsSL "${cdn}/manifest.json" -o "${raw}"

to_sri() {
  nix hash convert --hash-algo sha256 --to sri "$1"
}

version="$(jq -r '.version' "${raw}")"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "update.sh: CDN manifest missing version" >&2
  exit 1
fi

wasm_file="$(jq -r '.photonWasm.file' "${raw}")"
wasm_hex="$(jq -r '.photonWasm.sha256' "${raw}")"
if [[ "${wasm_file}" != "photon_rs_bg.wasm" || -z "${wasm_hex}" || "${wasm_hex}" == "null" ]]; then
  echo "update.sh: CDN manifest missing photonWasm.file/sha256" >&2
  exit 1
fi
wasm_hash="$(to_sri "${wasm_hex}")"

targets_json='{}'
for target in "${supported_targets[@]}"; do
  gz_file="$(jq -r --arg t "${target}" '.targets[$t].gz.file // empty' "${raw}")"
  gz_hex="$(jq -r --arg t "${target}" '.targets[$t].gz.sha256 // empty' "${raw}")"
  if [[ -z "${gz_file}" || -z "${gz_hex}" ]]; then
    echo "update.sh: CDN manifest missing gz sidecar for ${target}" >&2
    exit 1
  fi
  gz_hash="$(to_sri "${gz_hex}")"
  targets_json="$(
    jq -c --arg t "${target}" --arg file "${gz_file}" --arg hash "${gz_hash}" \
      '.[$t] = {file: $file, hash: $hash}' <<<"${targets_json}"
  )"
done

jq --arg version "${version}" \
  --arg wasmFile "${wasm_file}" \
  --arg wasmHash "${wasm_hash}" \
  --argjson targets "${targets_json}" \
  '{
    version: $version,
    photonWasm: {file: $wasmFile, hash: $wasmHash},
    targets: $targets
  }' >"${pkg_dir}/manifest.json"

echo "updated ${pkg_dir}/manifest.json to ${version}"
