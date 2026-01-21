{ callPackage }:

{
  hello-world = callPackage ./hello-world.nix { };
}
