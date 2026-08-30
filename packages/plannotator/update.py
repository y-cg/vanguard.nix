"""Update plannotator's checked-in hashes from GitHub release sidecars.

nix-update's default path only rewrites the hash for the host system, which
is how 0.27.9 landed with stale aarch64 hashes. Sidecar files are a few
dozen bytes; this script does not download the ~140MiB binaries.
"""

from __future__ import annotations

import base64
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Literal, TypedDict

System = Literal["x86_64-linux", "aarch64-linux", "x86_64-darwin", "aarch64-darwin"]
Arch = Literal["linux-x64", "linux-arm64", "darwin-x64", "darwin-arm64"]


class Source(TypedDict):
    arch: Arch
    hash: str


class Release(TypedDict):
    version: str
    sources: dict[System, Source]


REPO = "backnotprop/plannotator"
PLATFORMS: dict[System, Arch] = {
    "aarch64-darwin": "darwin-arm64",
    "aarch64-linux": "linux-arm64",
    "x86_64-darwin": "darwin-x64",
    "x86_64-linux": "linux-x64",
}
SOURCES_FILE = Path(
    os.environ.get(
        "PLANNOTATOR_SOURCES_FILE", Path(__file__).with_name("sources.json")
    )
)


def curl(url: str) -> bytes:
    cmd = ["curl", "-fsSL", "--connect-timeout", "10", "--max-time", "60"]
    token = os.environ.get("GITHUB_TOKEN")
    if token and "api.github.com" in url:
        cmd.extend(["-H", f"Authorization: Bearer {token}"])
    return subprocess.check_output(cmd + [url])


def sri_sha256(digest: str) -> str:
    return "sha256-" + base64.b64encode(bytes.fromhex(digest)).decode("ascii")


def latest_version() -> str:
    payload = json.loads(
        curl(f"https://api.github.com/repos/{REPO}/releases/latest")
    )
    tag = payload["tag_name"]
    return tag[1:] if tag.startswith("v") else tag


def sidecar_hash(version: str, arch: Arch) -> str:
    url = (
        f"https://github.com/{REPO}/releases/download/v{version}/"
        f"plannotator-{arch}.sha256"
    )
    first = curl(url).decode("ascii").split()[0]
    if len(first) != 64:
        raise ValueError(f"unexpected sha256 sidecar for {arch}: {first!r}")
    return sri_sha256(first)


def release_from_github(version: str) -> Release:
    sources: dict[System, Source] = {}
    for system, arch in PLATFORMS.items():
        sources[system] = {"arch": arch, "hash": sidecar_hash(version, arch)}
    return {"version": version, "sources": sources}


def main(args: list[str]) -> None:
    version = next((arg for arg in args if arg), "") or latest_version()
    release = release_from_github(version)
    SOURCES_FILE.write_text(json.dumps(release, indent=2, sort_keys=True) + "\n")
    print(f"updated plannotator to {release['version']}")


if __name__ == "__main__":
    main(sys.argv[1:])
