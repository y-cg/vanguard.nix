{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "drive9";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "mem9-ai";
    repo = "drive9";
    rev = "ffe6663c97e0fc1c8ac2b1dafe03a54d32aee77e";
    hash = "sha256-JNZa59q/OtNrtTzlzVMQygUBNWcMNZYqBjYZ87XA5RQ=";
  };

  vendorHash = "sha256-j7HknWKS1DdZIFF7dPNp+KQb7JUYoVS5Y1oPDmHXyiw=";

  subPackages = [ "cmd/drive9" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/mem9-ai/drive9/pkg/buildinfo.Version=${finalAttrs.version}"
    "-X github.com/mem9-ai/drive9/pkg/buildinfo.GitHash=${finalAttrs.src.rev}"
    "-X github.com/mem9-ai/drive9/pkg/buildinfo.GitBranch=main"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };

  meta = {
    description = "Server-side workspace kernel for AI agents";
    homepage = "https://github.com/mem9-ai/drive9";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "drive9";
  };
})
