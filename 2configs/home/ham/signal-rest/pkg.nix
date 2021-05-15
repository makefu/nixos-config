{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pysignalclirestapi";
  version = "0.3.14";

  # disabled = ; # requires python version >=2.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "6f3626b594a53c4161dfc67ea7a3b23d62c8fe8cb404a909496118aeefa79cd0";
  };

  doCheck = false;

  meta = with lib; {
    description = "Small python library for the Signal Cli REST API";
    homepage = https://github.com/bbernhard/pysignalclirestapi;
    #license = licenses.;
    # maintainers = [ maintainers. ];
  };
}
