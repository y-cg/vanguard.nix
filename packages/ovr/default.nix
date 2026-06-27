{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "ovr";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "y-cg";
    repo = "ovr";
    rev = "0450034ccfcfd28d71ac6ca5b4bacd6a93f68e77";
    hash = "sha256-789IK0fwHNOfmKgkmf5iPEInFCRS1CkYH+/DFi6jxMg=";
  };

  vendorHash = "sha256-xMgvSB/ZQGXqjiUsWF5086/GGs2eQ29hdbowb2cvXXI=";

  subPackages = [ "cmd/ovr" ];

  meta = {
    description = "Deep-merge TOML, JSON, and YAML config files; later files override earlier ones";
    homepage = "https://github.com/y-cg/ovr";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ovr";
  };
})
