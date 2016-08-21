{ stdenv, boost, sqlite, fetchFromGitHub }:

stdenv.mkDerivation rec {
  proj = "udpt";
  name = "udpt-${rev}";
  rev = "0790558";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "naim94a";
    repo = "udpt";
    inherit rev;
    sha256 = "0rgkjwvnqwbnqy7pm3dk176d3plb5lypaf12533yr0yfzcp6gnzk";
  };
  buildInputs = [ boost sqlite ];
  installPhase = ''
    mkdir -p $out/bin $out/etc/
    cp udpt $out/bin
    cp udpt.conf $out/etc/
  '';
  meta = {
    description = "udp tracker";
    homepage = https://github.com/naim94a/udpt;
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
