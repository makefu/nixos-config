{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.pythonPackages;buildPythonPackage rec {
  name = "mycube-flask-${version}";
  version = "0.2.3";
  propagatedBuildInputs = [
    flask
    redis
  ];
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "mycube-flask";
    rev = "5f5260a";
    sha256 = "1jx0h81nlmi1xry2vw46rvsanq0sdca6hlq31lhh7klqrg885hgh";
  };
  meta = {
    homepage = https://github.com/makefu/mycube-flask;
    description = "flask app for mycube";
    license = lib.licenses.asl20;
  };
}
