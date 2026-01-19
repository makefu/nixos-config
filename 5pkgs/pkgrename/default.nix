{ lib, stdenv, fetchFromGitHub, curl
}:
stdenv.mkDerivation rec {
  name = "pkgrename";
  version = "1.05";

  src = fetchFromGitHub {
    owner = "hippie68";
    repo = "pkgrename";
    rev = "3b87fa6b24dc3b80048767ce5767fb595f9ce60c";
    sha256 = "sha256-wQ9wPS0xTMZ04JBiiP1/pfxZBsQdjcDM1GLLl+BImf4=";
  };

  buildInputs = [ curl.dev ];
  buildPhase = ''
    cd pkgrename.c
    $CC pkgrename.c src/*.c -o pkgrename -s -O3 $(curl-config  --cflags --libs) -Wl,--allow-multiple-definition
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
