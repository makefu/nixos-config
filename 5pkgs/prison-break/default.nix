{pkgs, fetchFromGitHub}:
with pkgs.python3.pkgs;

buildPythonPackage rec {
  pname = "prison-break";
  version = "1.5.0";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = pname;
    rev = version;
    sha256 = "sha256:0gk7g5k9hzscsdkddm6978m43f4cdv2nzr47sclhjl7g2x7v97pm";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
    notify2
    (callPackage ./straight-plugin.nix {})
  ];
  checkInputs = [ black ];
}
