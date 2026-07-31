{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "telemetrygen";
  version = "0.157.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector-contrib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-51EYUr83OpdCRqL9BIGE3x1g4j2yM2xjwpEZ4vS2QrE=";
  };

  vendorHash = "sha256-FH0g3nVrU5Vx8kr1Q0v8awg5+9tbgVxqvvEB4Ac7FeQ=";

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
