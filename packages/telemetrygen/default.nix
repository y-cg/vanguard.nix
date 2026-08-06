{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "telemetrygen";
  version = "0.158.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector-contrib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1CnEAyAN6oOYk/DO+5f8nKxBTjx/Ou2fBymxj3FyNKQ=";
  };

  vendorHash = "sha256-nPh2A68lMcQtwdqhc8cHLpYhNJKCopK8GWx6dABmWiI=";

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
