{ lib, stdenv, fetchFromGitHub , mbedtls, ninja, cmake }:
stdenv.mkDerivation rec {
  pname = "ps3dec";
  version = "20181216";

  src = fetchFromGitHub {
    owner = "al3xtjames";
    repo = "PS3Dec";
    rev = "7d1d27f";
    hash = "sha256-dgH9xMOAqDhfG2dWE+oX2wNqrcsSO8dMTo5f3ETSxTw=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ mbedtls  ];
  installPhase = ''
    install -D Release/PS3Dec $out/bin/PS3Dec
  '';

  meta = {
    description = "ISO encryptor/decryptor for PS3 disc images";
    homepage = "https://github.com/al3xtjames/PS3Dec";
    license = lib.licenses.free;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ makefu ];
    mainProgram = "PS3Dec";
  };
}
