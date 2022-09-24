{ buildPythonApplication,  fetchFromGitHub, feedparser, matrix-nio, docopt, aiohttp, aiofiles,
mypy }:

buildPythonApplication rec {
  pname = "mediawiki-matrix-bot";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "mediawiki-matrix-bot";
    rev = "v${version}";
    sha256 = "1923097j1xh34jmm0zhmvma614jcxaagj89c1fc1j2qyv14ybsvs";
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
