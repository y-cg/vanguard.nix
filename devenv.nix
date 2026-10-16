{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    uv
    nix-update
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt.enable = true;

  apple.sdk = null;

  # See full reference at https://devenv.sh/reference/options/
}
