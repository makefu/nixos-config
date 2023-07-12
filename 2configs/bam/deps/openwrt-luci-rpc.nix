{ lib
, buildPythonPackage
, fetchPypi
, click
, requests
, packaging
}:

buildPythonPackage rec {
  pname = "openwrt-luci-rpc";
  version = "1.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "174a1f6c0bb2a2ed76e5299d14e2be05c612e8bcd4c15b9a9aedee1ef8e18b90";
  };

  patchPhase = ''
    sed -i -e "s/requests==2.21.0/requests/" -e "s/packaging==19.1/packaging/" setup.py
  '';

  propagatedBuildInputs = [
    click
    requests
    packaging
  ];

  meta = with lib; {
    description = "Module for interacting with OpenWrt Luci RPC interface";
    homepage = https://github.com/fbradyirl/openwrt-luci-rpc;
    license = licenses.asl20;
    maintainers = [ maintainers.makefu ];
  };
}
