{ lib
, buildPythonPackage
, callPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "androidtv";
  version = "0.0.34";

  src = fetchPypi {
    inherit pname version;
    sha256 = "13078i2a9hglpv4ldycph5n5485np21vs6z2qn830hybmx8kfxsw";
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
