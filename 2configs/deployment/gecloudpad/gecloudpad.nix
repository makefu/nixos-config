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
    rev = "master";
    sha256 = "0p9lcphp3r7hyypxadzw4x9ix6d0anmspxnjnj0v2jjll8gxqlhf";
  };

  meta = {
    homepage = https://github.com/binaergeiwtter/gecloudpad;
    description = "server side for gecloudpad";
    license = lib.licenses.wtfpl;
  };
}

