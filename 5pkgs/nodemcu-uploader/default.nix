{ lib, pkgs, pythonPackages, fetchurl, ... }:

with pythonPackages; buildPythonPackage rec {
  name = "nodemcu-uploader-${version}";
  version = "0.2.2";
  disabled = isPy3k || isPyPy;
  propagatedBuildInputs = [
    pyserial
  ];
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/n/nodemcu-uploader/nodemcu-uploader-${version}.tar.gz";
    sha256 = "090giz84y9y3idgifp0yh80qqyv2czv6h3y55wyrlgf7qfbwbrvn";
  };
  # ImportError: No module named tests
  # not sure what to do here
  doCheck = false;
  meta = {
    homepage = https://github.com/kmpm/nodemcu-uploader;
    description = "tool for uploading files to NodeMCU filesystem";
    license = lib.licenses.mit;
  };
}
