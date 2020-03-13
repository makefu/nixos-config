{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "cheetah3";
  version = "3.2.4";


  src = fetchPypi {
    pname = "Cheetah3";
    inherit version;
    sha256 = "caabb9c22961a3413ac85cd1e5525ec9ca80daeba6555f4f60802b6c256e252b";
  };

  doCheck = false;

  meta = with lib; {
    description = "Cheetah is a template engine and code generation tool";
    homepage = https://cheetahtemplate.org/;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
