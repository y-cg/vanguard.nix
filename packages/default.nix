{
  callPackage,
  pkgs,
  opamNixLib,
}:

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
  claude-hud = callPackage ./claude-hud { };
  bttf = callPackage ./bttf { };
  vimhjkl = callPackage ./vimhjkl { };
  grit = callPackage ./grit { };
  wotfard = callPackage ./wotfard { };
  forester = callPackage ./forester { inherit pkgs opamNixLib; };
  ovr = callPackage ./ovr { };
}
