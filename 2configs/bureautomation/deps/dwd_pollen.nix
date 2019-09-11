{ lib
, buildPythonPackage
, fetchFromGitHub
, python
, voluptuous
}:

buildPythonPackage rec {
  format = "other";
  pname = "dwd_pollen";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "marcschumacher";
    repo = "dwd_pollen";
    rev = version;
    sha256 = "1af2mx99gv2hk1ad53g21fwkdfdbymqcdl3jvzd1yg7dgxlkhbj1";
  };
  propagatedBuildInputs = [
    voluptuous
  ];
  installPhase = ''
     install -D -t $out/${python.sitePackages}/homeassistant/components/sensor/dwd_pollen *
  '';

  meta = with lib; {
    description = "Home Assistant component to retrieve Pollen data from DWD (Germany)";
    homepage = https://github.com/marcschumacher/dwd_pollen;
    license = licenses.mit;
    maintainers = [ maintainers.makefu ];
  };
}
