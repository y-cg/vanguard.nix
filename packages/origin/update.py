#!/usr/bin/env python3
"""Update Origin's checked-in release metadata from Cursor's release manifest.

The Nix expression deliberately consumes ``release.json`` rather than being
rewritten by this script. That makes the release record the only mutable
surface: an upstream change cannot accidentally alter Nix code.
"""

import base64
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

# Cursor's own ``origin update`` command uses these channel manifests. We
# accept ``unstable`` only as a compatibility spelling for the ``latest``
# channel exposed by earlier versions of this package's update script.
CHANNEL_ALIASES = {"stable": "stable", "latest": "latest", "unstable": "latest"}
MANIFEST_URL = "https://downloads.cursor.com/co/channels/{channel}/manifest.json"

# Origin publishes more platforms than this derivation supports. Keeping this
# mapping explicit makes a newly supported platform an intentional packaging
# decision, while requiring every supported system to have an artifact.
PLATFORM_TO_SYSTEM = {
    "linux-x64": "x86_64-linux",
    "linux-arm64": "aarch64-linux",
    "darwin-x64": "x86_64-darwin",
    "darwin-arm64": "aarch64-darwin",
}
VERSION_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*\Z")
SHA256_PATTERN = re.compile(r"[0-9a-f]{64}\Z")
ROOT = Path(__file__).resolve().parent
PACKAGED_RELEASE_FILE = ROOT / "release.json"


class ReleaseError(ValueError):
    """The remote manifest is not safe to record as this package's release."""


def release_file_from_environment() -> Path:
    """Locate mutable metadata outside a store-packaged update script.

    ``nix-update`` copies this script into the Nix store, but runs its update
    script from the repository root. The Nix expression therefore supplies the
    checkout target explicitly. Direct execution retains the adjacent file as
    a convenient fallback.
    """

    configured_path = os.environ.get("ORIGIN_RELEASE_FILE")
    return Path(configured_path) if configured_path else PACKAGED_RELEASE_FILE


def sri_sha256(hex_digest: str) -> str:
    """Convert the manifest's hexadecimal SHA-256 to Nix's SRI form."""

    return "sha256-" + base64.b64encode(bytes.fromhex(hex_digest)).decode("ascii")


def fetch_manifest(channel: str) -> Any:
    """Fetch JSON with curl, whose user agent Cursor's CDN accepts reliably."""

    url = MANIFEST_URL.format(channel=channel)
    try:
        response = subprocess.run(
            ["curl", "-fsSL", "--connect-timeout", "10", "--max-time", "60", url],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip() or f"curl exited with status {error.returncode}"
        raise ReleaseError(f"could not fetch {url}: {detail}") from error

    try:
        return json.loads(response.stdout)
    except json.JSONDecodeError as error:
        raise ReleaseError(f"{url} did not contain valid JSON: {error}") from error


def validate_manifest(manifest: Any) -> dict[str, Any]:
    """Return the narrow release record Nix needs, or reject incompatible data.

    URLs are checked against the current CDN layout. If Cursor changes that
    layout, failing closed prompts a package review instead of silently
    broadening the derivation's download trust policy.
    """

    if not isinstance(manifest, dict):
        raise ReleaseError("manifest root must be an object")

    version = manifest.get("version")
    platforms = manifest.get("platforms")
    if not isinstance(version, str) or not VERSION_PATTERN.fullmatch(version):
        raise ReleaseError("manifest version must be a safe, non-empty path component")
    if not isinstance(platforms, dict):
        raise ReleaseError("manifest platforms must be an object")

    sources = {}
    for platform, system in PLATFORM_TO_SYSTEM.items():
        asset = platforms.get(platform)
        if not isinstance(asset, dict):
            raise ReleaseError(f"manifest has no {platform!r} artifact")

        url = asset.get("url")
        hex_digest = asset.get("sha256")
        expected_url = f"https://downloads.cursor.com/co/{version}/{platform}/co.tar.gz"
        if url != expected_url:
            raise ReleaseError(f"unexpected download URL for {platform}: {url!r}")
        if not isinstance(hex_digest, str) or not SHA256_PATTERN.fullmatch(hex_digest):
            raise ReleaseError(f"manifest has an invalid SHA-256 for {platform}")

        sources[system] = {"url": url, "hash": sri_sha256(hex_digest)}

    return {"version": version, "sources": sources}


def read_current_version(release_file: Path) -> str | None:
    """Read the previous version solely for a useful no-op message."""

    try:
        release = json.loads(release_file.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return None
    except json.JSONDecodeError as error:
        raise ReleaseError(f"{release_file} is not valid JSON: {error}") from error
    return release.get("version") if isinstance(release, dict) else None


def write_release(release: dict[str, Any], release_file: Path) -> None:
    """Write the generated, reviewable release record to the checkout."""

    release_file.write_text(
        json.dumps(release, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )


def main(arguments: list[str]) -> int:
    if len(arguments) > 1:
        raise ReleaseError("usage: update-origin [stable|latest|unstable]")
    requested_channel = arguments[0] if arguments else "stable"
    try:
        channel = CHANNEL_ALIASES[requested_channel or "stable"]
    except KeyError as error:
        raise ReleaseError(
            f"unknown channel {requested_channel!r} (expected stable, latest, or unstable)"
        ) from error

    release = validate_manifest(fetch_manifest(channel))
    release_file = release_file_from_environment()
    previous_version = read_current_version(release_file)
    if release["version"] == previous_version:
        print(f"origin is already at {release['version']} ({channel})")
        return 0

    write_release(release, release_file)
    print(
        f"updated origin {previous_version or 'unknown'} -> {release['version']} ({channel})"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except ReleaseError as error:
        raise SystemExit(f"update-origin: {error}") from error
