{ callPackage }:

{
  hello-world = callPackage ./hello-world.nix { };
  turbovault = callPackage ./turbovault.nix { };
}
