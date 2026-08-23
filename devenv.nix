{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  scripts = {
    # Keep package discovery and CI filtering in one implementation. The Python
    # wrapper also handles the inventory JSON emitted by newer Nix versions.
    list-pkgs.exec = ''
      ${lib.getExe pkgs.nix} flake show --json --all-systems |
        python3 scripts/list-packages.py "$@"
    '';

    list-ci-pkgs.exec = ''
      ${lib.getExe pkgs.nix} flake show --json --all-systems |
        python3 scripts/list-packages.py --ci "$@"
    '';
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    python3
    python3Packages.pydantic
    nix-update
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt.enable = true;

  apple.sdk = null;

  # See full reference at https://devenv.sh/reference/options/
}
