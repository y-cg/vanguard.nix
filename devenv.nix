{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  scripts = {
    list-pkgs.exec = ''
      nix flake show --json --all-systems | \
        jq -r ".packages.\"$@\" | to_entries[] | .key" | \
        jq -R -s -c 'split("\n") | map(select(length > 0))'
    '';
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [ jq ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
