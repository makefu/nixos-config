{ lib, stdenv,  fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hactool";
  name = "${pname}-${version}";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "SciresM";
    repo = "hactool";
    rev = version;
    sha256 = "162zv7my79a5ssn6zwk1yh64jjwlzr9kiplbpyvj4ly79dpngwyn";
  };

  preBuild = ''
    cp config.mk.template config.mk
  '';

  installPhase = ''
    install -D hactool $out/bin/hactool
  '';

  meta = {
    description = "tool to view information about, decrypt, and extract common file formats for the Nintendo Switch, especially Nintendo Content Archives";
    homepage = https://github.com/SciresM/hactool;
    license = stdenv.lib.licenses.isc;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
