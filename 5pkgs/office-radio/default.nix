{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "office-radio-${version}";
  version = "0.2.3.4";
  propagatedBuildInputs = [
      flask
      psutil
      mpd2
      requests
  ];
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "office-radio";
    rev = "601c650";
    sha256 = "06zf0sjm4zlnbjlmiajbz1klhz1maj1ww5vah2abcvk1vx0p0hn7";
  };
  meta = {
    homepage = https://github.com/makefu/office-radio;
    description = "manage virtual office radio";
    license = lib.licenses.asl20;
  };
}
