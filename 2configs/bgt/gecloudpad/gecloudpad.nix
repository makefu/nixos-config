{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "gecloudpad-${version}";
  version = "0.2.3";
  pyproject = true;
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    flask requests
  ];

  src = fetchFromGitHub {
    owner = "binaergewitter";
    repo = "gecloudpad";
    rev = "73e3947889169407048582423999d689a6d0e3b7";
    sha256 = "sha256-B9KnE/DzRSSpw4WmGiITZ3wHWnbEnqtGqDYT11LgTLE=";
  };

  meta = {
    homepage = https://github.com/binaergewitter/gecloudpad;
    description = "server side for gecloudpad";
    license = lib.licenses.wtfpl;
  };
}

