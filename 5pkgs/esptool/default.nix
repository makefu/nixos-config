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
    name = "esptool-${version}";
    version = "2.0beta2";
    propagatedBuildInputs = [
      pyserial
      flake8
      ecdsa
      pyaes
    ];
    src = fetchFromGitHub {
      owner = "themadinventor";
      repo = "esptool";
      rev = "v${version}";
      sha256 = "0n96pyi1k4qlyfqk5k7xpgq8726wz74qvd3gqjg0bpsl3wr7l94i";
    };
    doCheck = false;
}
