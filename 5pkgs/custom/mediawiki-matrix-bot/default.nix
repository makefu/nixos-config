{ buildPythonApplication,  fetchFromGitHub, feedparser, matrix-nio, docopt, aiohttp, aiofiles,
mypy }:

buildPythonApplication rec {
  pname = "mediawiki-matrix-bot";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "mediawiki-matrix-bot";
    rev = "v${version}";
    hash = "sha256-TLSoEskzS5xEu6DEFoztaHSWVm0UO7oYCNSxVY0I4cQ=";
  };
  propagatedBuildInputs = [
    feedparser matrix-nio docopt aiohttp aiofiles
  ];
  nativeBuildInputs = [
    mypy
  ];

  doCheck = false;
  #checkInputs = [
  #  types-aiofiles
  #];
  #checkPhase = ''
  #  mypy --strict mediawiki_matrix_bot
  #'';
}
