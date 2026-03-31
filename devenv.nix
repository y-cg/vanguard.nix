{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  scripts = {
    # First, list every package exposed by the flake for a target system.
    # Other scripts build on top of this so there is a single source of truth for
    # package discovery.
    list-pkgs.exec = ''
      nix flake show --json --all-systems | \
        jq -r --arg sys "$1" '(.packages[$sys] // {}) | to_entries[] | .key' | \
        jq -R -s -c 'split("\n") | map(select(length > 0))'
    '';

    # CI and local verification both use this script so callers can test exactly
    # the package selection they intend to ship. The first argument is the target
    # system and any remaining arguments are packages to quarantine.
    list-ci-pkgs.exec = ''
      if [ "$#" -lt 1 ]; then
        echo "usage: list-ci-pkgs <system> [skipped-package ...]" >&2
        exit 1
      fi

      system="$1"
      shift

      # Convert the remaining positional arguments into the JSON array shape that
      # jq expects for membership checks. We keep this inline so callers can vary
      # the quarantine list without editing devenv configuration.
      skipped_packages_json="$(jq -cn '$ARGS.positional' --args "$@")"

      list-pkgs "$system" | \
        jq -c --argjson skipped "$skipped_packages_json" '
          map(select(. as $package | ($skipped | index($package) | not)))
        '
      # TODO: If we later need package-specific skip reasons in CI output, accept a
      # structured input format instead of plain package-name arguments.
    '';
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    jq
    nix-update
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
