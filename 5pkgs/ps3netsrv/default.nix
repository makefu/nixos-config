{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, mbedtls
}:

stdenv.mkDerivation rec {
  pname = "ps3netsrv";
  version = "20220813";

  src = fetchFromGitHub {
    owner = "aldostools";
    repo = "webMAN-MOD";
    rev = "5301277a0eb2275c73d7c82af9cb9e9ec34369e4";
    hash = "sha256-hgQSqRKFomHgOr1ejfKoR/Sywa3AjbinmAAgscVYs44=";
  };
  postUnpack = "pwd; ls -alhtr; ls -alhtr source";

  #dontUseCmakeConfigure = true;
  nativeBuildInputs = [ mbedtls meson ninja ];
  buildInputs = [ mbedtls ];
  sourceRoot = "./source/_Projects_/ps3netsrv";

  meta = with lib; {
    homepage = "https://github.com/aldostools/webMAN-MOD/wiki/~-PS3-NET-Server";
    description = "a server application used to stream content from a remote server to the PS3";
    maintainers = [ maintainers.makefu ];
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
