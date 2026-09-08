# pdf2htmlEX vendors Poppler and FontForge from source: it includes private
# Poppler headers (OutputDev, CharCodeToUnicode, …) that were removed in
# Poppler 24.10+, so a distro Poppler will not work. Upstream's buildScripts
# pin the versions below (see buildScripts/versionEnvs) and compile them as
# static trees in sibling directories that CMakeLists.txt hardcodes.
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchpatch,
  cmake,
  pkg-config,
  python3,
  jre_headless,
  cairo,
  freetype,
  fontconfig,
  glib,
  libjpeg,
  libpng,
  libxml2,
  openjpeg,
  zlib,
  gettext,
  libiconv,
  uthash,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pdf2htmlEX";
  version = "0.18.8.rc2";

  src = fetchFromGitHub {
    name = "source";
    owner = "pdf2htmlEX";
    repo = "pdf2htmlEX";
    rev = "cb7806aecbbee435e086be248fa068fbe3dc24c9";
    hash = "sha256-w/Y1sEGdP/GOdOLEGQy+nEAxPJR2BeQROc9N2Nf5BqA=";
  };

  # Pinned to match buildScripts/versionEnvs on that commit.
  popplerSrc = fetchurl {
    url = "https://poppler.freedesktop.org/poppler-24.06.1.tar.xz";
    hash = "sha256-HmKehzIobHRfvAsVo+5ZFEP7N6IhCFbn8+w4oPuTqxM=";
  };

  popplerDataSrc = fetchurl {
    url = "https://poppler.freedesktop.org/poppler-data-0.4.12.tar.gz";
    hash = "sha256-yDW2QKQM41fhuDZmqr2V7f+iTd3dSbja/2OtuFHNq3Q=";
  };

  fontforgeSrc = fetchFromGitHub {
    name = "fontforge-src";
    owner = "fontforge";
    repo = "fontforge";
    rev = "20230101";
    hash = "sha256-/RYhvL+Z4n4hJ8dmm+jbA1Ful23ni2DbCRZC5A3+pP0=";
  };

  fontforgePatches = [
    (fetchpatch {
      name = "CVE-2024-25081.CVE-2024-25082.patch";
      url = "https://github.com/fontforge/fontforge/commit/216eb14b558df344b206bf82e2bdaf03a1f2f429.patch";
      hash = "sha256-aRnir09FSQMT50keoB7z6AyhWAVBxjSQsTRvBzeBuHU=";
    })
    (fetchpatch {
      name = "update-translation-compatibility.patch";
      url = "https://github.com/fontforge/fontforge/commit/642d8a3db6d4bc0e70b429622fdf01ecb09c4c10.patch";
      hash = "sha256-uO9uEhB64hkVa6O2tJKE8BLFR96m27d8NEN9UikNcvg=";
    })
  ];

  # CMakeLists.txt lives in the pdf2htmlEX/ subdir and looks for
  # ../poppler/build and ../fontforge/build.
  sourceRoot = "source/pdf2htmlEX";

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
    jre_headless
    gettext
  ];

  buildInputs = [
    cairo
    freetype
    fontconfig
    glib
    libjpeg
    libpng
    libxml2
    openjpeg
    zlib
    gettext
    libiconv
    uthash
  ];

  patches = [ ./cmake-pkg-config.patch ];

  env.PDF2HTMLEX_VERSION = finalAttrs.version;
  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

  postUnpack = ''
    # unpackPhase only chmods sourceRoot (source/pdf2htmlEX); the repo root
    # stays 555 from the Nix store copy, so sibling extracts would fail.
    chmod -R u+w source

    tar -xf ${finalAttrs.popplerSrc} -C source
    mv source/poppler-24.06.1 source/poppler

    mkdir -p source/fontforge
    cp -a ${finalAttrs.fontforgeSrc}/. source/fontforge
    chmod -R u+w source/fontforge
    for patch in ${toString finalAttrs.fontforgePatches}; do
      echo "applying fontforge patch $patch"
      patch -d source/fontforge -p1 < "$patch"
    done

    tar -xf ${finalAttrs.popplerDataSrc} -C source
    mv source/poppler-data-0.4.12 source/poppler-data
    chmod -R u+w source/poppler source/poppler-data
  '';

  cmakeFlags = [
    "-DENABLE_SVG=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  # Upstream buildScripts/buildPoppler and buildFontforge, adapted for Nix.
  # PIC is required because Nix links PIE executables on Linux.
  preConfigure = ''
    cmakePopplerFontforge() {
      local srcDir="$1"
      shift
      pushd "$srcDir"
      cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$out" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        "$@"
      cmake --build build --parallel "$NIX_BUILD_CORES"
      popd
    }

    cmakePopplerFontforge ../poppler \
      -DBUILD_SHARED_LIBS=OFF \
      -DENABLE_UNSTABLE_API_ABI_HEADERS=OFF \
      -DBUILD_GTK_TESTS=OFF \
      -DBUILD_QT5_TESTS=OFF \
      -DBUILD_QT6_TESTS=OFF \
      -DBUILD_CPP_TESTS=OFF \
      -DBUILD_MANUAL_TESTS=OFF \
      -DENABLE_BOOST=OFF \
      -DENABLE_SPLASH=ON \
      -DENABLE_UTILS=OFF \
      -DENABLE_CPP=OFF \
      -DENABLE_GLIB=ON \
      -DENABLE_GOBJECT_INTROSPECTION=OFF \
      -DENABLE_GTK_DOC=OFF \
      -DENABLE_QT5=OFF \
      -DENABLE_QT6=OFF \
      -DENABLE_LIBOPENJPEG=openjpeg2 \
      -DENABLE_DCTDECODER=libjpeg \
      -DENABLE_CMS=none \
      -DENABLE_LCMS=OFF \
      -DENABLE_LIBCURL=OFF \
      -DENABLE_LIBTIFF=OFF \
      -DWITH_TIFF=OFF \
      -DWITH_NSS3=OFF \
      -DENABLE_NSS3=OFF \
      -DENABLE_GPGME=OFF \
      -DENABLE_ZLIB=ON \
      -DENABLE_ZLIB_UNCOMPRESS=OFF \
      -DUSE_FLOAT=OFF \
      -DRUN_GPERF_IF_PRESENT=OFF \
      -DEXTRA_WARN=OFF \
      -DWITH_JPEG=ON \
      -DWITH_PNG=ON \
      -DWITH_Cairo=ON

    cmakePopplerFontforge ../fontforge \
      -DBUILD_SHARED_LIBS=OFF \
      -DENABLE_GUI=OFF \
      -DENABLE_X11=OFF \
      -DENABLE_NATIVE_SCRIPTING=ON \
      -DENABLE_PYTHON_SCRIPTING=OFF \
      -DENABLE_PYTHON_EXTENSION=OFF \
      -DENABLE_LIBSPIRO=OFF \
      -DENABLE_LIBUNINAMESLIST=OFF \
      -DENABLE_LIBGIF=OFF \
      -DENABLE_LIBJPEG=ON \
      -DENABLE_LIBPNG=ON \
      -DENABLE_LIBREADLINE=OFF \
      -DENABLE_LIBTIFF=OFF \
      -DENABLE_WOFF2=OFF \
      -DENABLE_DOCS=OFF \
      -DENABLE_CODE_COVERAGE=OFF
  '';

  postInstall = ''
    make -C "$NIX_BUILD_TOP/source/poppler-data" install \
      prefix="$out" datadir="$out/share/pdf2htmlEX"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/pdf2htmlEX";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Convert PDF to HTML without losing text or format";
    homepage = "https://github.com/pdf2htmlEX/pdf2htmlEX";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pdf2htmlEX";
    platforms = lib.platforms.linux;
  };
})
