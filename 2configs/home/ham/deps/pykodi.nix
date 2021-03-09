{ lib
, buildPythonPackage
, fetchPypi
, jsonrpc-async
, jsonrpc-websocket
, aiohttp
}:

buildPythonPackage rec {
  pname = "pykodi";
  version = "0.2.2";

  disabled = false; # requires python version >=3.7.0

  src = fetchPypi {
    inherit pname version;
    sha256 = "43e7036a00a76f65c34dc5e7f1065a3ef071eea7619c2e6228e521b638e640bc";
  };

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # jsonrpc-async>=1.1.0
  # jsonrpc-websocket>=1.2.1
  propagatedBuildInputs = [
    jsonrpc-async
    jsonrpc-websocket
    aiohttp
  ];

  meta = with lib; {
    description = "An async python interface for Kodi over JSON-RPC";
    homepage = https://github.com/OnFreund/PyKodi;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
