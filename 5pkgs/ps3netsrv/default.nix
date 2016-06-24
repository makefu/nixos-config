{ stdenv, fetchgit, clang, makeWrapper, gnugrep }:

stdenv.mkDerivation rec {
  name = "ps3netsrv-${version}";
  version = "1.1.0";

  enableParallelBuilding = true;

  src = fetchgit {
    url = "https://github.com/dirkvdb/ps3netsrv--";
    fetchSubmodules = true;
    rev = "e54a66cbf142b86e2cffc1701984b95adb921e81"; # latest @ 2016-05-24
    sha256 = "0l7bp18cs3xr2qgsmcf18diccski49mj9whngxm9isi8wd4r9inj";
  };

  nativeBuildInputs = [ gnugrep ];
  buildPhase = "make CXX=g++";
  installPhase = ''
    mkdir -p $out/bin
    cp ps3netsrv++ $out/bin
  '';
  meta = {
    description = "C++ implementation of the ps3netsrv server";
    homepage = https://github.com/dirkvdb/ps3netsrv--;
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
