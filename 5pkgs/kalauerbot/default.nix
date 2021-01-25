{ stdenv, python3, fetchgit }:
python3.pkgs.buildPythonPackage rec {
name = "kalauerbot";
rev = "2a1e868";
  src = fetchgit {
    url = "http://cgit.euer.krebsco.de/kalauerbot";
    inherit rev;
    sha256 = "1vymz3dnpgcxwfgbnrpc0plcdmihxcq7xsvpap755c5jvzvb8a1k";
  };
  propagatedBuildInputs = with python3.pkgs;[
     (callPackage ./python-matrixbot.nix {
      matrix-client = (stdenv.lib.overrideDerivation matrix-client (self: {
      patches = [ ./badsync.patch ];
    }));
    })

    (stdenv.lib.overrideDerivation googletrans (self: {
      patches = [ ./translate.patch ];
    }))
  ];
  checkInputs = [ python3.pkgs.black ];
}

