{ lib
, buildPythonPackage
, fetchpatch
, fetchPypi
, aiohttp
, async-timeout
}:

buildPythonPackage rec {
  pname = "pyhaversion";
  version = "2.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "72b65aa25d7b2dbb839a4d0218df2005c2335e93526035904d365bb668030b9f";
  };
  patches = [
    (fetchpatch { url = "https://github.com/makefu/pyhaversion/commit/f3bdc38970272cd345c2cfbde3037ea492ca27c4.patch";
    sha256 =
      "1rhq4z7mdgnwhwpf5fmarnbc1ba3qysk1wqjdr0hvbzi8vmvbfcc";})
  ];
  doCheck = false;
  propagatedBuildInputs = [
    aiohttp
    async-timeout
  ];

  meta = with lib; {
    description = "";
    homepage = https://github.com/ludeeus/pyhaversion;
    # maintainers = [ maintainers. ];
  };
}
