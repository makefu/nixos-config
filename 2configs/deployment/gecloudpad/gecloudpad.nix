{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "gecloudpad-${version}";
  version = "0.2.3";

  propagatedBuildInputs = [
    flask requests
  ];

  src = fetchFromGitHub {
    owner = "binaergewitter";
    repo = "gecloudpad";
    rev = "1399ede4e609f63fbf1c4560979a6b22b924e0c5";
    sha256 = "1w74j5ks7naalzrib87r0adq20ik5x3x5l520apagb7baszn17lb";
  };

  meta = {
    homepage = https://github.com/binaergeiwtter/gecloudpad;
    description = "server side for gecloudpad";
    license = lib.licenses.wtfpl;
  };
}

