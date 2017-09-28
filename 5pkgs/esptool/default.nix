{ pkgs, fetchFromGitHub, ... }:
with pkgs.python2Packages;
let
  pyaes = buildPythonPackage rec {
      name = "pyaes-${version}";
      version = "1.6.0";
      src = fetchFromGitHub {
        owner = "ricmoo";
        repo = "pyaes";
        rev = "v${version}";
        sha256 = "04934a9zgwc8g3qhfrkcfv0bs557paigllnkrnfhp9m1azr3bfqb";
      };
      doCheck = false;
  };
in
  buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "esptool";
    version = "2.1";
    propagatedBuildInputs = [
      pyserial
      flake8
      ecdsa
      pyaes
    ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "08g393fiqhanixzjbs54pqr6xk1a4dsfaddw7gdwfvp3kvwdn2fp";
    };
    doCheck = false;
  }
