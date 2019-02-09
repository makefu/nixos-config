{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "ampel-${version}";
  version = "0.2.4";

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
      rev = "04e1c8c38ffe53175ae719121ad88534a8a662db";
      sha256 = "00jgr3jg2yi91hd7388v8rncfbq8fx8dvr03sg749dzpsg58hfxn";
  };
  meta = {
    homepage = http://cgit.euer.krebsco.de/ampel;
    description = "change colors of rgb cubes";
    license = lib.licenses.asl20;
  };
}
