{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "opendal-oli";
  version = "0.41.23";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "3d6e427e8c0c92aec1430e2f4bbb777e4e08d81e";
    hash = "sha256-X6QOFs94jOQeZySmSyWP3VVgPyWNC8ihW2IFu9loKR0=";
  };

  cargoHash = "sha256-58pYGU1XwP3AsEugeXuqPmPuXGXSwVz/Aq7KaKAfNtQ=";

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenDAL command line interface for manipulating data across storage services";
    homepage = "https://github.com/apache/opendal-oli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "oli";
  };
})
