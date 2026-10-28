{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "telemetrygen";
  version = "0.164.1";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector-contrib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9/sbCEb9qVzDYf7aBIx7EJM4Ls9ZctR21iVL7jQ1684=";
  };

  vendorHash = "sha256-Y0GU/wC4yTFQ+giysGj3MHFnLwhJmo4Qjff9uZMYtiI=";

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
