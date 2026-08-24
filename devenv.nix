{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  scripts = {
    # Package discovery and policy selection share one interface. Callers choose
    # a view such as `--select cache-skip` or `--select update-script`; the
    # default remains every package exposed for the requested system.
    list-pkgs.exec = ''
      ${lib.getExe pkgs.nix} flake show --json --all-systems |
        python3 scripts/list-packages.py "$@"
    '';
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    python3
    nix-update
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt.enable = true;

  apple.sdk = null;

  # See full reference at https://devenv.sh/reference/options/
}
