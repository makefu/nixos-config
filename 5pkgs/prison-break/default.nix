{pkgs, fetchFromGitHub}:
with pkgs.python3.pkgs;

buildPythonPackage rec {
  pname = "prison-break";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = pname;
    rev = "1.0.0";
    sha256 = "0ab42z6qr42vz4fc077irn9ykrrylagx1dzlw8dqcanf49dxd961";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
    (callPackage ./straight-plugin.nix {})
  ];
  checkInputs = [ black ];
}
