{ lib, stdenv, fetchzip, mbedtls, meson, ninja }:
let
  webManModVersion = "1.47.45";
in
stdenv.mkDerivation rec {
  pname = "ps3netsrv";
  version = "20231215";

  src = fetchzip {
    url = "https://github.com/aldostools/webMAN-MOD/releases/download/${webManModVersion}/${pname}_${version}.zip";
    hash = "sha256-DKERYn9QZ7hAcbAApWTby+jdM1Nz6kU+hZO4T2CvH0o=";
  };

  sourceRoot = "./source/${pname}";

  buildInputs = [ ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-Doff64_t=off_t";

  buildPhase = ''
    runHook preBuild
    make -f Makefile.linux BUILD_TYPE=release
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 ps3netsrv $out/bin/ps3netsrv
    install -Dm644 LICENSE.TXT $out/usr/share/licenses/${pname}/LICENSE.TXT 
    runHook postInstall
  '';

  meta = {
    description = "PS3 Net Server (mod by aldostools)";
    homepage = "https://github.com/aldostools/webMAN-MOD/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ makefu ];
    mainProgram = "ps3netsrv";
  };
}
