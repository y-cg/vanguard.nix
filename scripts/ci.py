"""Decide which packages CI builds and updates.

package-policy.toml is the only place that says how a package is built or
updated. Run from the repository root:

    uv run --project scripts scripts/ci.py --help
"""

from __future__ import annotations

import json
import shlex
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Annotated, Literal, NoReturn

import tomllib
import typer
from pydantic import BaseModel, ConfigDict

ROOT = Path(__file__).resolve().parent.parent
POLICY_FILE = ROOT / "package-policy.toml"

# Systems we build, and the runner each one builds on.
RUNNERS = {
    "x86_64-linux": "ubuntu-latest",
    "aarch64-linux": "ubuntu-24.04-arm",
    "aarch64-darwin": "macos-latest",
}

# A change to one of these can affect every package.
SHARED_FILES = {
    "flake.nix",
    "flake.lock",
    "packages/default.nix",
    "package-policy.toml",
}
SHARED_DIRS = ("scripts/", ".github/")

Track = Literal["stable", "unstable"]


class Policy(BaseModel):
    """How one package is built and updated. Fields match package-policy.toml."""

    model_config = ConfigDict(extra="forbid")

    cache: Literal["push", "skip"] = "push"
    update: Literal["nix-update", "github-releases", "update-script", "manual"] = (
        "nix-update"
    )
    track: Track = "stable"


@dataclass
class Inventory:
    systems: dict[str, set[str]]
    defaults: Policy
    overrides: dict[str, Policy]

    def names(self) -> set[str]:
        return set().union(*self.systems.values())

    def policy(self, name: str) -> Policy:
        return self.overrides.get(name, self.defaults)


app = typer.Typer(no_args_is_help=True, add_completion=False)


def fail(message: str) -> NoReturn:
    typer.echo(f"ci: {message}", err=True)
    raise typer.Exit(1)


def run(command: list[str]) -> str:
    result = subprocess.run(
        command, cwd=ROOT, capture_output=True, text=True, check=False
    )
    if result.returncode != 0:
        fail(f"{shlex.join(command)} failed:\n{result.stderr}")
    return result.stdout


def load_inventory() -> Inventory:
    """Package names per system, read with `nix eval` (no derivation is built)."""
    names = json.loads(
        run(
            [
                "nix",
                "eval",
                "--json",
                ".#packages",
                "--apply",
                "ps: builtins.mapAttrs (_: builtins.attrNames) ps",
            ]
        )
    )
    systems = {
        system: set(packages) for system, packages in names.items() if system in RUNNERS
    }

    raw = tomllib.loads(POLICY_FILE.read_text())
    defaults = Policy.model_validate(raw.pop("defaults", {}))
    overrides = {
        name: Policy.model_validate(defaults.model_dump() | table)
        for name, table in raw.items()
    }

    inventory = Inventory(systems, defaults, overrides)
    stale = sorted(set(overrides) - inventory.names())
    if stale:
        fail(f"package-policy.toml names packages the flake does not expose: {stale}")
    return inventory


# ---------------------------------------------------------------------------
# Builds
# ---------------------------------------------------------------------------


def changed_packages(base: str, head: str, known: set[str]) -> set[str] | None:
    """Packages touched by base...head, or None when every package must build.

    Anything that cannot be pinned to one package selects all of them.
    """
    changed = run(["git", "diff", "--name-only", f"{base}...{head}"]).splitlines()
    selected: set[str] = set()
    for path in changed:
        if path in SHARED_FILES or path.startswith(SHARED_DIRS):
            return None
        parts = path.split("/")
        if parts[0] != "packages":
            continue
        if len(parts) < 3:
            return None  # a loose file in packages/
        package = parts[1]
        if package in known:
            selected.add(package)
        elif (ROOT / "packages" / package).is_dir():
            return None  # a directory the flake does not expose
        # Otherwise the package was deleted and has nothing left to build.
    return selected


@app.command()
def build_matrix(
    event: Annotated[str, typer.Option(help="GitHub event name")] = "",
    base: Annotated[str, typer.Option(help="Base revision of the change")] = "",
    head: Annotated[str, typer.Option(help="Head revision of the change")] = "HEAD",
) -> None:
    """Print the (package, system) jobs to build for a change, as JSON."""
    inventory = load_inventory()
    # A manual run, or a push with no usable base (new branch), builds everything.
    if event == "workflow_dispatch" or not base.strip("0"):
        selected = None
    else:
        selected = changed_packages(base, head, inventory.names())
    include = [
        {
            "package": package,
            "system": system,
            "os": runner,
            "cache": inventory.policy(package).cache,
        }
        for system, runner in RUNNERS.items()
        for package in sorted(inventory.systems.get(system, set()))
        if selected is None or package in selected
    ]
    print(json.dumps({"include": include}))


# ---------------------------------------------------------------------------
# Updates
# ---------------------------------------------------------------------------


def nix_update_args(package: str, policy: Policy) -> list[str]:
    if policy.update == "update-script":
        # The package's own updater picks the version; nix-update only runs it.
        return ["nix-update", "--flake", package, "--use-update-script"]
    args = ["nix-update", "--flake", package, f"--version={policy.track}"]
    if policy.update == "github-releases":
        args.append("--use-github-releases")
    return args


def run_update(package: str, policy: Policy) -> bool:
    args = nix_update_args(package, policy)
    typer.echo(f"+ {shlex.join(args)}", err=True)
    return subprocess.run(args, cwd=ROOT, check=False).returncode == 0


def publish(package: str, policy: Policy, base: str) -> None:
    """Commit the update on its own branch, push it, and open or refresh its PR."""
    suffix = "-unstable" if policy.track == "unstable" else ""
    branch = f"update/{package}{suffix}"
    title = f"chore({package}): update package{' (unstable)' if suffix else ''}"
    body = (
        f"Automated update of `{package}` by [nix-update]"
        "(https://github.com/Mic92/nix-update).\n\n"
        f"Release track: `{policy.track}`\n"
    )

    run(["git", "switch", "--force-create", branch, base])
    run(["git", "add", "--all"])
    run(["git", "commit", "--message", title])
    run(["git", "push", "--force", "origin", branch])

    open_prs = run(
        ["gh", "pr", "list", "--head", branch, "--state", "open", "--json", "number"]
    )
    if json.loads(open_prs):
        return  # the push already refreshed the existing pull request
    run(
        [
            "gh",
            "pr",
            "create",
            "--head",
            branch,
            "--title",
            title,
            "--body",
            body,
            "--label",
            "automated",
            "--label",
            "dependencies",
        ]
    )


def reset_worktree(base: str) -> None:
    run(["git", "switch", "--detach", base])
    run(["git", "reset", "--hard", base])
    run(["git", "clean", "--force", "-d"])


@app.command()
def update_all(
    track: Annotated[Track, typer.Option(help="Release track to update")] = "stable",
    dry_run: Annotated[
        bool,
        typer.Option(help="Run the updates, but do not push or open pull requests"),
    ] = False,
) -> None:
    """Update every automatically updated package on a track, one pull request each."""
    inventory = load_inventory()
    base = run(["git", "rev-parse", "HEAD"]).strip()
    failed: list[str] = []

    for package in sorted(inventory.names()):
        policy = inventory.policy(package)
        if policy.update == "manual" or policy.track != track:
            continue

        reset_worktree(base)
        if not run_update(package, policy):
            typer.echo(f"{package}: update failed", err=True)
            failed.append(package)
            continue
        if not run(["git", "status", "--porcelain"]).strip():
            typer.echo(f"{package}: already up to date")
            continue
        if dry_run:
            typer.echo(f"{package}: changed (dry run, not published)")
            typer.echo(run(["git", "diff", "--stat"]))
            continue
        publish(package, policy, base)

    reset_worktree(base)
    if failed:
        fail(f"update failed for: {', '.join(failed)}")


@app.command()
def update(package: Annotated[str, typer.Argument(help="Package to update")]) -> None:
    """Update one package in the working tree, the way its policy says."""
    inventory = load_inventory()
    if package not in inventory.names():
        fail(f"unknown package: {package}")
    policy = inventory.policy(package)
    if policy.update == "manual":
        fail(f"{package} is maintained by hand")
    raise typer.Exit(0 if run_update(package, policy) else 1)


if __name__ == "__main__":
    app()
