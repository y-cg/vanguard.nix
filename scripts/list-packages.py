#!/usr/bin/env python3
"""List packages exposed by a flake for a target system."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import NoReturn

from pydantic import BaseModel, ConfigDict, Field, ValidationError


class ArgumentParser(argparse.ArgumentParser):
    """Avoid breaking the producer pipe when reporting invalid arguments."""

    def error(self, message: str) -> NoReturn:
        if not sys.stdin.isatty():
            sys.stdin.buffer.read()
        super().error(message)


class Package(BaseModel):
    """The package metadata emitted by `nix flake show`."""

    model_config = ConfigDict(extra="ignore", strict=True)

    name: str | None = None
    description: str | None = None
    type: str | None = None


class FlakeOutput(BaseModel):
    """The subset of flake output JSON consumed by this script."""

    model_config = ConfigDict(extra="ignore", strict=True)

    packages: dict[str, dict[str, Package]]


class CiSkip(BaseModel):
    """Packages intentionally excluded from CI builds."""

    model_config = ConfigDict(extra="ignore", strict=True)

    packages: list[str] = Field(default_factory=list)


def parse_flake_output(value: object) -> FlakeOutput:
    """Validate and convert the flake JSON into the domain model."""
    return FlakeOutput.model_validate(value)


def package_names(flake: FlakeOutput, system: str, skipped: set[str]) -> list[str]:
    """Return sorted package attributes for a system, excluding skipped names."""
    return sorted(
        name for name in flake.packages.get(system, {}) if name not in skipped
    )


def load_input() -> FlakeOutput:
    return parse_flake_output(json.load(sys.stdin))


def load_ci_skip() -> CiSkip:
    path = Path(__file__).resolve().parent.parent / "ci-skip.json"
    try:
        with path.open() as stream:
            return CiSkip.model_validate_json(stream.read())
    except FileNotFoundError:
        return CiSkip()


def main() -> int:
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("system", help="flake system, for example x86_64-linux")
    parser.add_argument(
        "--ci",
        action="store_true",
        help="exclude packages listed in ci-skip.json",
    )
    args = parser.parse_args()

    try:
        flake = load_input()
        skip = load_ci_skip() if args.ci else CiSkip()
    except (json.JSONDecodeError, ValidationError) as error:
        print(f"list-packages: invalid JSON: {error}", file=sys.stderr)
        return 1

    print(json.dumps(package_names(flake, args.system, set(skip.packages))))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
