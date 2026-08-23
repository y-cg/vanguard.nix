"""Update Origin's checked-in release metadata from Cursor's manifest."""

import base64
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Literal, TypedDict, cast

Channel = Literal["stable", "latest"]
Platform = Literal["linux-x64", "linux-arm64", "darwin-x64", "darwin-arm64"]
System = Literal["x86_64-linux", "aarch64-linux", "x86_64-darwin", "aarch64-darwin"]


class Asset(TypedDict):
    url: str
    sha256: str


class Manifest(TypedDict):
    version: str
    platforms: dict[Platform, Asset]


class Source(TypedDict):
    url: str
    hash: str


class Release(TypedDict):
    version: str
    sources: dict[System, Source]


CHANNELS: dict[str, Channel] = {
    "stable": "stable",
    "latest": "latest",
    "unstable": "latest",
}
PLATFORMS: dict[Platform, System] = {
    "linux-x64": "x86_64-linux",
    "linux-arm64": "aarch64-linux",
    "darwin-x64": "x86_64-darwin",
    "darwin-arm64": "aarch64-darwin",
}
MANIFEST_URL = "https://downloads.cursor.com/co/channels/{channel}/manifest.json"
RELEASE_FILE = Path(
    os.environ.get("ORIGIN_RELEASE_FILE", Path(__file__).with_name("release.json"))
)


def fetch_manifest(channel: Channel) -> Manifest:
    url = MANIFEST_URL.format(channel=channel)
    output = subprocess.check_output(
        ["curl", "-fsSL", "--connect-timeout", "10", "--max-time", "60", url],
        text=True,
    )
    return cast(Manifest, json.loads(output))


def sri_sha256(digest: str) -> str:
    return "sha256-" + base64.b64encode(bytes.fromhex(digest)).decode("ascii")


def release_from_manifest(manifest: Manifest) -> Release:
    version = manifest["version"]
    sources: dict[System, Source] = {}
    for platform, system in PLATFORMS.items():
        asset = manifest["platforms"][platform]
        sources[system] = {
            "url": asset["url"],
            "hash": sri_sha256(asset["sha256"]),
        }
    return {"version": version, "sources": sources}


def main(args: list[str]) -> None:
    channel_name = args[0] if args else "stable"
    channel = CHANNELS[channel_name]
    release = release_from_manifest(fetch_manifest(channel))
    RELEASE_FILE.write_text(json.dumps(release, indent=2, sort_keys=True) + "\n")
    print(f"updated origin to {release['version']} ({channel})")


if __name__ == "__main__":
    main(sys.argv[1:])
