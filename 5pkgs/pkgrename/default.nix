{ lib, stdenv, fetchFromGitHub, curl
}:
stdenv.mkDerivation rec {
  name = "pkgrename";
  version = "1.05";

  src = fetchFromGitHub {
    owner = "hippie68";
    repo = "pkgrename";
    rev = "c7c95f0ea49324433db4a7df8db8b0905198e62e";
    sha256 = "komFm9VRdH4DPxcnHzbm/sGVEWMbfcvFPLEFdbU/K5g=";
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
