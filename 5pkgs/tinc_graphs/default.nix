{stdenv,fetchurl,pkgs,python3Packages, ... }:

python3Packages.buildPythonPackage rec {
  name = "tinc_graphs-${version}";
  version = "0.3.6";
  propagatedBuildInputs = with pkgs;[
    python3Packages.pygeoip
    ## ${geolite-legacy}/share/GeoIP/GeoIPCity.dat
  ];
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/t/tinc_graphs/tinc_graphs-${version}.tar.gz";
    sha256 = "0ghdx9aaipmppvc2b6cgks4nxw6zsb0fhjrmnisbx7rz0vjvzc74";
  };
  preFixup = with pkgs;''
    wrapProgram $out/bin/build-graphs --prefix PATH : "$out/bin"
    wrapProgram $out/bin/all-the-graphs --prefix PATH : "${imagemagick}/bin:${graphviz}/bin:$out/bin"
    wrapProgram $out/bin/tinc-stats2json --prefix PATH : "${tinc}/bin"
  '';

  meta = {
    homepage = http://krebsco.de/;
    description = "Create Graphs from Tinc Stats";
    license = stdenv.lib.licenses.wtfpl;
  };
}

