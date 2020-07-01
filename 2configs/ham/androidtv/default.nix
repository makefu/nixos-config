{ lib
, buildPythonPackage
, callPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "androidtv";
  version = "0.0.41";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1nch08g47qjgdacl03w7kczx2gajx6nkazgxdzbgn1vghrg6x2zw";
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
