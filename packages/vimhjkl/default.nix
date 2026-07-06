{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vimhjkl";
  version = "0.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "S-Sigdel";
    repo = "vimhjkl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uBXz2O2PwtnmibaR4e/l+lKIUh7WN2Hvh6nUfpUuEeA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.11,<0.12" uv_build
  '';

  build-system = with python3Packages; [ uv-build ];

  doCheck = false;

  meta = with lib; {
    description = "Learn Vim from your terminal with spaced repetition";
    homepage = "https://github.com/S-Sigdel/vimhjkl";
    changelog = "https://github.com/S-Sigdel/vimhjkl/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "vimhjkl";
  };
})
