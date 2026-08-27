#!/usr/bin/env python3
"""Select flake packages according to the repository package policy."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from typing import NoReturn

import tomllib

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_POLICY_PATH = REPOSITORY_ROOT / "package-policy.toml"


class ArgumentParser(argparse.ArgumentParser):
    """Avoid breaking the producer pipe when reporting invalid arguments."""

    def error(self, message: str) -> NoReturn:
        if not sys.stdin.isatty():
            sys.stdin.buffer.read()
        super().error(message)


@dataclass(frozen=True)
class FlakeOutput:
    """Only package attribute names matter; derivation metadata stays opaque."""

    packages: dict[str, frozenset[str]]


@dataclass(frozen=True)
class PackagePolicy:
    """Repository-owned exceptions shared by CI and automated updates."""

    cache_exclude: frozenset[str]
    update_script: frozenset[str]
    update_exclude: frozenset[str]
    update_unstable: frozenset[str]
    update_github_releases: frozenset[str]

    def configured_packages(self) -> frozenset[str]:
        """Return every package name mentioned by an exception."""
        return frozenset().union(
            self.cache_exclude,
            self.update_script,
            self.update_exclude,
            self.update_unstable,
            self.update_github_releases,
        )


class PackageSelection(StrEnum):
    """Stable selectors exposed to shell and workflow callers."""

    ALL = "all"
    CACHE_PUSH = "cache-push"
    CACHE_SKIP = "cache-skip"
    UPDATE = "update"
    UPDATE_DEFAULT = "update-default"
    UPDATE_SCRIPT = "update-script"
    UPDATE_EXCLUDED = "update-excluded"
    UPDATE_UNSTABLE = "update-unstable"
    UPDATE_GITHUB_RELEASES = "update-github-releases"


def parse_flake_output(value: object) -> FlakeOutput:
    """Accept both the classic and Nix 2.34 inventory output schemas."""
    root = require_table(value, "flake output")
    if "packages" in root:
        packages = require_table(root["packages"], "flake output.packages")
        return FlakeOutput(packages=parse_classic_packages(packages))

    inventory = require_table(root.get("inventory"), "flake output.inventory")
    package_inventory = require_table(
        inventory.get("packages"), "flake output.inventory.packages"
    )
    output = require_table(
        package_inventory.get("output"), "flake output.inventory.packages.output"
    )
    systems = require_table(
        output.get("children"), "flake output.inventory.packages.output.children"
    )
    packages: dict[str, frozenset[str]] = {}
    for system, node in systems.items():
        if not isinstance(system, str):
            raise TypeError("package inventory system names must be strings")
        system_node = require_table(node, f"package inventory.{system}")
        # Without --all-systems, Nix preserves the other system names as
        # `filtered` placeholders. They are not empty package sets.
        if "children" not in system_node:
            continue
        children = require_table(
            system_node["children"], f"package inventory.{system}.children"
        )
        packages[system] = frozenset(str(package) for package in children)
    return FlakeOutput(packages=packages)


def parse_classic_packages(
    packages: dict[object, object],
) -> dict[str, frozenset[str]]:
    """Read the pre-inventory `packages.<system>.<name>` shape."""
    systems: dict[str, frozenset[str]] = {}
    for system, package_outputs in packages.items():
        if not isinstance(system, str):
            raise TypeError("flake output package-system names must be strings")
        package_table = require_table(
            package_outputs, f"flake output.packages.{system}"
        )
        if not all(isinstance(package, str) for package in package_table):
            raise ValueError(f"flake output.packages.{system} has a non-string key")
        systems[system] = frozenset(package_table)
    return systems


def require_table(value: object, location: str) -> dict[object, object]:
    """Return a mapping or report the precise invalid input location."""
    if not isinstance(value, dict):
        raise TypeError(f"{location} must be a table/object")
    return value


def string_list(table: dict[object, object], key: str, location: str) -> frozenset[str]:
    """Read one duplicate-free TOML string list."""
    value = table.get(key, [])
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise ValueError(f"{location}.{key} must be an array of strings")
    if len(value) != len(set(value)):
        raise ValueError(f"{location}.{key} contains duplicate package names")
    return frozenset(value)


def reject_unknown_keys(
    table: dict[object, object], allowed: set[str], location: str
) -> None:
    """Make policy typos fail closed instead of silently changing CI behavior."""
    unknown = sorted(str(key) for key in table if key not in allowed)
    if unknown:
        raise ValueError(f"{location} contains unknown keys: {unknown}")


def parse_policy(value: object) -> PackagePolicy:
    """Validate TOML and enforce mutually exclusive update strategies."""
    root = require_table(value, "package policy")
    reject_unknown_keys(root, {"cache", "update"}, "package policy")
    cache = require_table(root.get("cache", {}), "package policy.cache")
    update = require_table(root.get("update", {}), "package policy.update")
    reject_unknown_keys(cache, {"exclude"}, "package policy.cache")
    reject_unknown_keys(
        update,
        {"script", "exclude", "unstable", "github-releases"},
        "package policy.update",
    )

    policy = PackagePolicy(
        cache_exclude=string_list(cache, "exclude", "package policy.cache"),
        update_script=string_list(update, "script", "package policy.update"),
        update_exclude=string_list(update, "exclude", "package policy.update"),
        update_unstable=string_list(update, "unstable", "package policy.update"),
        update_github_releases=string_list(
            update, "github-releases", "package policy.update"
        ),
    )
    update_categories = {
        "script": policy.update_script,
        "exclude": policy.update_exclude,
        "unstable": policy.update_unstable,
        "github-releases": policy.update_github_releases,
    }
    for left, right in (
        ("script", "exclude"),
        ("script", "unstable"),
        ("script", "github-releases"),
        ("exclude", "unstable"),
        ("exclude", "github-releases"),
    ):
        overlap = sorted(update_categories[left] & update_categories[right])
        if overlap:
            raise ValueError(f"update.{left} and update.{right} overlap: {overlap}")
    return policy


def package_names(
    flake: FlakeOutput,
    system: str,
    policy: PackagePolicy,
    selection: PackageSelection,
) -> list[str]:
    """Return the selected package attributes for one system."""
    available = set(flake.packages.get(system, frozenset()))
    cache_skip = set(policy.cache_exclude)
    update_script = set(policy.update_script)
    update_excluded = set(policy.update_exclude)
    update_unstable = set(policy.update_unstable)
    update_github_releases = set(policy.update_github_releases)

    selections = {
        PackageSelection.ALL: available,
        PackageSelection.CACHE_PUSH: available - cache_skip,
        PackageSelection.CACHE_SKIP: available & cache_skip,
        PackageSelection.UPDATE: available - update_excluded,
        PackageSelection.UPDATE_DEFAULT: available - update_excluded - update_script,
        PackageSelection.UPDATE_SCRIPT: available & update_script,
        PackageSelection.UPDATE_EXCLUDED: available & update_excluded,
        PackageSelection.UPDATE_UNSTABLE: available & update_unstable,
        PackageSelection.UPDATE_GITHUB_RELEASES: available & update_github_releases,
    }
    return sorted(selections[selection])


def load_input() -> FlakeOutput:
    return parse_flake_output(json.load(sys.stdin))


def load_policy(path: Path) -> PackagePolicy:
    """Load the human-maintained TOML policy from an explicit path."""
    with path.open("rb") as stream:
        return parse_policy(tomllib.load(stream))


def validate_policy_packages(flake: FlakeOutput, policy: PackagePolicy) -> None:
    """Catch stale or misspelled policy entries before a workflow silently skips them."""
    exposed = {
        package
        for packages_for_system in flake.packages.values()
        for package in packages_for_system
    }
    unknown = sorted(policy.configured_packages() - exposed)
    if unknown:
        raise ValueError(
            f"policy references packages not exposed by the flake: {unknown}"
        )


def main() -> int:
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("system", help="flake system, for example x86_64-linux")
    parser.add_argument(
        "--select",
        choices=list(PackageSelection),
        default=PackageSelection.ALL,
        type=PackageSelection,
        help="package policy view to emit (default: all)",
    )
    parser.add_argument(
        "--policy",
        type=Path,
        default=DEFAULT_POLICY_PATH,
        help="package policy TOML path",
    )
    args = parser.parse_args()

    try:
        flake = load_input()
        policy = load_policy(args.policy)
        validate_policy_packages(flake, policy)
    except (
        json.JSONDecodeError,
        OSError,
        tomllib.TOMLDecodeError,
        TypeError,
        ValueError,
    ) as error:
        print(f"list-packages: invalid input: {error}", file=sys.stderr)
        return 1

    print(json.dumps(package_names(flake, args.system, policy, args.select)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
