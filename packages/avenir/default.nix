{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "avenir-fonts";

  src = ./.;

  installPhase = ''
    install -Dm644 Avenir.ttc $out/share/fonts/truetype/Avenir.ttc
    install -Dm644 "Avenir Next.ttc" $out/share/fonts/truetype/"Avenir Next.ttc"
    install -Dm644 "Avenir Next Condensed.ttc" $out/share/fonts/truetype/"Avenir Next Condensed.ttc"
  '';

  meta = with pkgs.lib; {
    description = "Avenir font family";
    longDescription = ''
      Avenir is a sans-serif font family designed by Adrian Frutiger.
      It features a clean, geometric design with excellent readability.
      This package includes Avenir, Avenir Next, and Avenir Next Condensed variants.
    '';
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
