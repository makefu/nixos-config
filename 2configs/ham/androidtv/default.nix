{ lib
, buildPythonPackage
, callPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "androidtv";
  version = "0.0.38";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ri1fnc63zashc667w2mlpb0c7ri3x6wnhnf54klb89v73pdnb8k";
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
