{ lib, stdenv, fetchFromGitHub, curl
}:
stdenv.mkDerivation rec {
  name = "pkgrename";
  version = "1.03";

  src = fetchFromGitHub {
    owner = "hippie68";
    repo = "pkgrename";
    rev = "c3e5c47ed9367273bd09577af46d3d9bf87b2a50";
    sha256 = "0cphxdpj04h1i0qf5mji3xqdsbyilvd5b4gwp4vx914r6k5f0xf3";
  };

  buildInputs = [ curl.dev ];
  buildPhase = ''
    cd pkgrename.c
    gcc pkgrename.c src/*.c -o pkgrename -lcurl -s -O1 $(curl-config  --cflags --libs)
  '';
  installPhase = ''
    install -D pkgrename $out/bin/pkgrename
  '';

  meta = {
    description = "Tool to rename ps4 .pkg files";
    homepage = "https://github.com/hippie68/pkgrename";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ makefu ];
  };
}
