{ python3Packages, fetchFromGitHub }:

with python3Packages;
buildPythonPackage rec {
  name = "hydra-check";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "makefu";
    repo = "hydra-check";
    rev = version;
    sha256 = "0359s9rvl2q23a3yddhbn6w2sd5r1f1jl6whyik7qql7blpcvyi7";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
  ];

  checkInputs = [ black jq ];
}
