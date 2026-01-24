{ callPackage }:

{
  hello-world = callPackage ./hello-world.nix { };
  turbovault = callPackage ./turbovault.nix { };
  jj-starship = callPackage ./jj-starship.nix { };
}
