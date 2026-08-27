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
  launchdeck = callPackage ./launchdeck { };
  forester = callPackage ./forester { inherit pkgs opamNixLib; };
  ovr = callPackage ./ovr { };
  paseo = callPackage ./paseo { };
  ctx = callPackage ./ctx { };
  dnsglobe = callPackage ./dnsglobe { };
  telemetrygen = callPackage ./telemetrygen { };
  opendal-oli = callPackage ./opendal-oli { };
  drive9 = callPackage ./drive9 { };
  origin = callPackage ./origin { };
  raft-computer = callPackage ./raft-computer { };
  plannotator = callPackage ./plannotator { };
  fff-mcp = callPackage ./fff-mcp { };
}
