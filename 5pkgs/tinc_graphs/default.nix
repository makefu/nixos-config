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
    sha256 = "0fm063qhjlb8g1xahwcqqrd2dxgd38wwi55rhl1k5chr7zajsqfz";
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

