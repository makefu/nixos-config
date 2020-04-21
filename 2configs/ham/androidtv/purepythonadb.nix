{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pure-python-adb";
  version = "0.2.2.dev0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1xigv6c8xyb4g852nr3smz0137rnp81jvlikza071y7rc6pdzwza";
  };

  meta = with lib; {
    description = "Pure python implementation of the adb client";
    homepage = https://github.com/Swind/pure-python-adb;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
