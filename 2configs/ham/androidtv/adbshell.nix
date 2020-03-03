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
  version = "0.0.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "01f9jinhfyjldg9793gz2i7gcd9xyx0a62r7a5ijssklcnn2rwnm";
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
