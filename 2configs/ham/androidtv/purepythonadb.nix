{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pure-python-adb";
  version = "0.2.3.dev0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "88e5a4578435197799aa368fb1a5d87fe43e02a888cb7e85c2ad66173b383c89";
  };

  meta = with lib; {
    description = "Pure python implementation of the adb client";
    homepage = https://github.com/Swind/pure-python-adb;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}