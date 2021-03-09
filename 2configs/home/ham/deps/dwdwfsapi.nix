{ lib
, buildPythonPackage
, fetchPypi
, requests
, ciso8601
, urllib3
}:

buildPythonPackage rec {
  pname = "dwdwfsapi";
  version = "1.0.3";

  disabled = false; # requires python version >=3.6

  src = fetchPypi {
    inherit pname version;
    sha256 = "3d7d5bd66b1a647f07295068dc653b4ceafc2e8ec834b8e32419031c7b3a9b39";
  };

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # requests>=2.23.0,<3
  # ciso8601>=2.1.3,<3
  # urllib3>=1.25.8,<2
  propagatedBuildInputs = [
    requests
    ciso8601
    urllib3
  ];

  meta = with lib; {
    description = "Python client to retrieve data provided by DWD via their geoserver WFS API";
    homepage = https://github.com/stephan192/dwdwfsapi;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
