"""Update raft-computer's checked-in release metadata from the public CDN."""

import base64
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Literal, TypedDict, cast

Target = Literal["darwin-arm64", "darwin-x64", "linux-arm64", "linux-x64"]


class Sidecar(TypedDict):
    file: str
    hash: str


class Manifest(TypedDict):
    version: str
    photonWasm: Sidecar
    targets: dict[Target, Sidecar]


SUPPORTED_TARGETS: tuple[Target, ...] = (
    "darwin-arm64",
    "darwin-x64",
    "linux-arm64",
    "linux-x64",
)
CDN = os.environ.get("RAFT_COMPUTER_RELEASE_BASE", "https://cdn.raft.build/computer")
MANIFEST_FILE = Path(
    os.environ.get(
        "RAFT_COMPUTER_MANIFEST_FILE", Path(__file__).with_name("manifest.json")
    )
)


def fetch_cdn_manifest() -> dict:
    url = f"{CDN}/manifest.json"
    output = subprocess.check_output(
        ["curl", "-fsSL", "--connect-timeout", "10", "--max-time", "60", url],
        text=True,
    )
    return cast(dict, json.loads(output))


def sri_sha256(digest: str) -> str:
    return "sha256-" + base64.b64encode(bytes.fromhex(digest)).decode("ascii")


def release_from_cdn(raw: dict) -> Manifest:
    version = raw["version"]
    wasm = raw["photonWasm"]
    if wasm["file"] != "photon_rs_bg.wasm":
        raise KeyError("photonWasm.file")
    targets: dict[Target, Sidecar] = {}
    for target in SUPPORTED_TARGETS:
        gz = raw["targets"][target]["gz"]
        targets[target] = {"file": gz["file"], "hash": sri_sha256(gz["sha256"])}
    return {
        "version": version,
        "photonWasm": {"file": wasm["file"], "hash": sri_sha256(wasm["sha256"])},
        "targets": targets,
    }


def main(_args: list[str]) -> None:
    release = release_from_cdn(fetch_cdn_manifest())
    MANIFEST_FILE.write_text(json.dumps(release, indent=2, sort_keys=True) + "\n")
    print(f"updated raft-computer to {release['version']}")


if __name__ == "__main__":
    main(sys.argv[1:])
