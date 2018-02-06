{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "ampel-${version}";
  version = "0.2";

  propagatedBuildInputs = [
    docopt
    paho-mqtt
    requests
    pytz
    influxdb
    httplib2
    google_api_python_client
  ];

  src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/ampel";
      rev = "d8a0250";
      sha256 = "0n36lc17ca5db6pl6dswdqd5w9f881rfqck9yc4w33a5qpsxj85f";
  };
  meta = {
    homepage = http://cgit.euer.krebsco.de/ampel;
    description = "change colors of rgb cubes";
    license = lib.licenses.asl20;
  };
}
