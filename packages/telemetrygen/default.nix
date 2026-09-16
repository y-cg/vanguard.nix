{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "telemetrygen";
  version = "0.161.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector-contrib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L2LLY0S0s0pG9/84z1DVcmbaT8WaxJKeLrB5PkaBNeQ=";
  };

  vendorHash = "sha256-RLaWPWZW5O6oa5b6aYokkA851U+BWzjzZlo7MaJ0mbA=";

  sourceRoot = "${finalAttrs.src.name}/cmd/telemetrygen";

  subPackages = [ "." ];

  env.CGO_ENABLED = "0";

  doCheck = false;

  meta = {
    description = "Telemetry generator for OpenTelemetry (traces, metrics, and logs)";
    homepage = "https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/telemetrygen";
    changelog = "https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "telemetrygen";
  };
})
