{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "telemetrygen";
  version = "0.160.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector-contrib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Un9tJJhB4iM6yYQeLCB7sFTNVL644Gqr1/QG58VNopk=";
  };

  vendorHash = "sha256-Un7feseJLmqwyU9bmoasbfE73jIOAzIAREYPUQbEYhs=";

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
