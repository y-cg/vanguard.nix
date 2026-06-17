{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "wotfard-fonts";

  src = ./.;

  installPhase = ''
    runHook preInstall
    install -Dm644 *.otf -t $out/share/fonts/opentype/
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Wotfard font family";
    longDescription = ''
      Wotfard is a monospaced sans-serif typeface designed by atipo.
      This package includes the light, regular, and medium weights in
      both upright and italic styles.
    '';
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
