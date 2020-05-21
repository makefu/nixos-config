{ lib
, buildPythonPackage
, callPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "androidtv";
  version = "0.0.39";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06lrjj74g2f3pkhsn3c8h13mkykgqqf4g9q6x5yv23z6ghjnk2dz";
  };

  propagatedBuildInputs = [
    (callPackage ./adbshell.nix {})
    (callPackage ./purepythonadb.nix {})
  ];

  # tests are not packaged in pypi release
  doCheck = false; 

  meta = with lib; {
    description = "Communicate with an Android TV or Fire TV device via ADB over a network";
    homepage = https://github.com/JeffLIrion/python-androidtv/;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
