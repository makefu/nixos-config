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
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16wb8n4fsh465fjlbsxi83xpi7xklaf28s9568bsb3nkyvfvl58h";
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
