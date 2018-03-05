{ lib, pkgs, python2Packages, ... }:
# requires libusb1 from unstable
with (import <nixpkgs-unstable> {}).python2Packages; let

 python-adb = buildPythonPackage rec {
    name = "python-adb-${version}";
    version = "1.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "python-adb";
      rev = "28d912a";
      sha256 = "1cy18l96v72hrhf21im5i8hlzd8ilv0vcck026npnxiw095a5hm2";
    };

    propagatedBuildInputs = [ libusb1 m2crypto ];
    meta = {
      homepage = https://github.com/google/python-adb;
      description = "Python ADB + Fastboot implementation";
      license = lib.licenses.apache2;
    };
  };
in
 buildPythonPackage rec {
  name = "python-firetv-${version}";
  version = "1.0.5";

  src = pkgs.fetchFromGitHub {
    owner = "happyleavesaoc";
    repo = "python-firetv";
    rev = version;
    sha256 = "0j5p8jg13hc9gcbv0ipxgljrpcxk8b7k4p4kyfhmblpjm51mycs3";
  };

  propagatedBuildInputs = [ python-adb flask pyyaml ];
  meta = {
    homepage = https://github.com/happyleavesaoc/python-firetv;
    description = "provides state informations and some control of an amazon firetv";
    license = lib.licenses.mit;
  };
}
