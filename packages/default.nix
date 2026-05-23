{ callPackage }:

{
  hello-world = callPackage ./hello-world { };
  avenir = callPackage ./avenir { };
  turbovault = callPackage ./turbovault { };
  jj-starship = callPackage ./jj-starship { };
  jj-ryu = callPackage ./jj-ryu { };
  ai-shell = callPackage ./ai-shell { };
  lumen = callPackage ./lumen { };
  cloudflare-speed-cli = callPackage ./cloudflare-speed-cli { };
  envelope = callPackage ./envelope { };
  npc = callPackage ./npc { };
  models = callPackage ./models { };
  zensical = callPackage ./zensical { };
}
