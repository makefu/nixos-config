{stdenv,fetchurl,pkgs,python3Packages, ... }:

python3Packages.buildPythonPackage rec {
  name = "tinc_graphs-${version}";
  version = "0.2.9";
  propagatedBuildInputs = with pkgs;[
    python3Packages.pygeoip
    ## ${geolite-legacy}/share/GeoIP/GeoIPCity.dat
  ];
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/t/tinc_graphs/tinc_graphs-${version}.tar.gz";
    sha256 = "1rvy07ybjpqlsf9qizdp0zyq4ibd6w74k4glbbkw0x7j3j2skzdk";
  };
  preFixup = with pkgs;''
    wrapProgram $out/bin/build-graphs --prefix PATH : "${imagemagick}/bin:${graphviz}/bin"
  '';
  meta = {
    homepage = http://krebsco.de/;
    description = "Create Graphs from Tinc Stats";
    license = stdenv.lib.licenses.wtfpl;
  };
}

