{ buildPythonApplication,  fetchFromGitHub, feedparser, matrix-nio, docopt, aiohttp, aiofiles,
mypy }:

buildPythonApplication rec {
  pname = "mediawiki-matrix-bot";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "mediawiki-matrix-bot";
    rev = "refs/heads/custom_api_path";
    hash = "sha256-KhXXG9h1GgZfrivtSYa1GL6xpfCuPwreffkhWSw6Kzg";
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
