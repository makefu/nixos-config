{ stdenv, lib, python3, fetchgit }:
python3.pkgs.buildPythonPackage rec {
name = "kalauerbot";
rev = "f244b35";
  src = fetchgit {
    url = "http://cgit.euer.krebsco.de/kalauerbot";
    inherit rev;
    sha256 = "08y4rlsil9p0726wlpkw2lpmkcnckaj3zqsifbj5w6rgivp6ly0v";
  };
  propagatedBuildInputs = with python3.pkgs;[
     (callPackage ./python-matrixbot.nix {
      matrix-client = (lib.overrideDerivation matrix-client (self: {
      patches = [ ./badsync.patch ];
    }));
    })

    (lib.overrideDerivation googletrans (self: {
      patches = [ ./translate.patch ];
    }))
  ];
  checkInputs = [ python3.pkgs.black ];
}

