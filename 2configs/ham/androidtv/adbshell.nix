{ lib
, buildPythonPackage
, fetchPypi
, cryptography
, pyasn1
, rsa
, pycryptodome
}:

buildPythonPackage rec {
  pname = "adb_shell";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0a4mjrnw2lrhsakb1vjb5l6m3cr1ii7fibs7020nwv08cyx6pq6q";
  };

  propagatedBuildInputs = [
    cryptography
    pyasn1
    rsa
  ];

  # tests are not part of pypi package
  doCheck = false;

  checkInputs = [
    pycryptodome
  ];

  meta = with lib; {
    description = "A Python implementation of ADB with shell and FileSync functionality";
    homepage = https://github.com/JeffLIrion/adb_shell/;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
