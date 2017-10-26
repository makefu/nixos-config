{ pkgs, fetchFromGitHub, ... }:
with pkgs.python3Packages;
buildPythonPackage rec {
    pname = "internetarchive";
    version = "1.7.3";
    name = "${pname}-${version}";
    propagatedBuildInputs = [
      requests
      jsonpatch
      docopt
      clint
      six
      schema
      backports_csv
    ];

    # check only works when cloned from git repo
    doCheck = false;
    checkInputs = [
      pytest
      responses
    ];

    prePatch = ''
      sed -i "s/'schema.*'/'schema>=0.4.0'/" setup.py
    '';

    src = fetchPypi {
      inherit pname version;
      sha256 = "0x3saklabdx7qrr11h5bjfd75hfbih7pw5gvl2784zvvvrqrz45g";
    };
}
