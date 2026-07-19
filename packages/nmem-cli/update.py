#!/usr/bin/env python3
"""Bump nmem-cli version and all platform wheel hashes from PyPI.

Used as passthru.updateScript so the flake's update-packages workflow can
refresh every supported wheel in one shot (vanilla nix-update only knows
about the current system's src.outputHash).

nix-update invokes this with cwd = flake root, so we always write the
checkout copy of default.nix — not the read-only store path of this script.
"""

from __future__ import annotations

import base64
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

PYPI_JSON = "https://pypi.org/pypi/nmem-cli/json"
RELATIVE_NIX = Path("packages/nmem-cli/default.nix")

# (distro_needle, arch_needle) must uniquely select one wheel filename.
SYSTEM_MATCHERS: dict[str, tuple[str, str]] = {
    "x86_64-linux": ("manylinux", "x86_64"),
    "aarch64-linux": ("manylinux", "aarch64"),
    "x86_64-darwin": ("macosx", "x86_64"),
    "aarch64-darwin": ("macosx", "arm64"),
}


def to_sri(hex_digest: str) -> str:
    return "sha256-" + base64.b64encode(bytes.fromhex(hex_digest)).decode()


def platform_tag(filename: str) -> str:
    # nmem_cli-<ver>-py3-none-<platform>.whl
    return filename.rsplit("-", 1)[-1].removesuffix(".whl")


def select_wheel(urls: list[dict], distro: str, arch: str) -> dict:
    matches = [
        u
        for u in urls
        if u.get("packagetype") == "bdist_wheel"
        and distro in u["filename"]
        and arch in u["filename"]
    ]
    if len(matches) != 1:
        names = [u["filename"] for u in matches]
        raise SystemExit(f"expected 1 wheel for {distro}/{arch}, got {names!r}")
    return matches[0]


def locate_nix_file() -> Path:
    checkout = Path.cwd() / RELATIVE_NIX
    if checkout.is_file() and os.access(checkout, os.W_OK):
        return checkout
    sibling = Path(__file__).resolve().parent / "default.nix"
    if sibling.is_file() and os.access(sibling, os.W_OK):
        return sibling
    raise SystemExit(
        f"cannot locate writable {RELATIVE_NIX} (cwd={Path.cwd()}, script={__file__})"
    )


def main() -> int:
    nix_file = locate_nix_file()

    with urllib.request.urlopen(PYPI_JSON) as resp:
        data = json.load(resp)

    version = data["info"]["version"]
    urls = data["urls"]

    wheels: dict[str, dict[str, str]] = {}
    for system, (distro, arch) in SYSTEM_MATCHERS.items():
        wheel = select_wheel(urls, distro, arch)
        wheels[system] = {
            "platform": platform_tag(wheel["filename"]),
            "hash": to_sri(wheel["digests"]["sha256"]),
        }

    text = nix_file.read_text()
    text, n = re.subn(
        r'(version = ")[^"]+(";)',
        rf"\g<1>{version}\g<2>",
        text,
        count=1,
    )
    if n != 1:
        raise SystemExit(f"failed to rewrite version in {nix_file}")

    block = ["      wheels = {"]
    for system in SYSTEM_MATCHERS:
        w = wheels[system]
        block.extend(
            [
                f"        {system} = {{",
                f'          platform = "{w["platform"]}";',
                f'          hash = "{w["hash"]}";',
                "        };",
            ]
        )
    block.append("      };")
    new_block = "\n".join(block)

    text, n = re.subn(
        r"      wheels = \{.*?\n      \};",
        new_block,
        text,
        count=1,
        flags=re.DOTALL,
    )
    if n != 1:
        raise SystemExit(f"failed to rewrite wheels attrset in {nix_file}")

    nix_file.write_text(text)
    print(f"nmem-cli -> {version} ({nix_file})")
    for system, w in wheels.items():
        print(f"  {system}: {w['platform']} {w['hash']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
