{ lib, stdenv, fetchFromGitHub, curl
}:
stdenv.mkDerivation rec {
  name = "sfo";
  version = "1.02";

  src = fetchFromGitHub {
    owner = "hippie68";
    repo = "sfo";
    rev = "b38cf18d8a5c60a7f05a604b8a67215b7fb67e0a";
    sha256 = "141yyd5lgdz5vbghl3ncaxh3nvv6p03gks0ib3dnrif1lpbbj9ai";
  };

  buildInputs = [ curl.dev ];
  buildPhase = ''
    gcc sfo.c -o sfo
  '';
  installPhase = ''
    install -D sfo $out/bin/sfo
  '';

  meta = {
    description = "program that reads a file to print or modify its SFO parameters";
    homepage = "https://github.com/hippie68/sfo";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ makefu ];
  };
}
