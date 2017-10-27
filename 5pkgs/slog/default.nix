{ pkgs, stdenv, fetchFromGitHub }:

## Posix shell logging, use with:
# . $(command -v slog.sh)
stdenv.mkDerivation rec {
  name = "slog-${version}";
  version = "2017-10-27";

  src = fetchFromGitHub {
    owner = "makefu";
    repo = "slog";
    rev = "50367c3";
    sha256 = "16wlh8xz430101lrxmgl2wangbbhvyj4pg8k5aibnh76sgj6x77r";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m755 slog.sh $out/bin
  '';
}
