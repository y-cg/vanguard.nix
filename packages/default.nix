{ callPackage }:

{
  hello-world = callPackage ./hello-world.nix { };
  turbovault = callPackage ./turbovault.nix { };
  jj-starship = callPackage ./jj-starship.nix { };
  jj-ryu = callPackage ./jj-ryu.nix { };
  ai-shell = callPackage ./ai-shell.nix { };
  lumen = callPackage ./lumen { };
}
