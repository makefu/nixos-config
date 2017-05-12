{ pkgs, fetchFromGitHub, ... }:
with pkgs.python3Packages;
let
  asyncio-irc = buildPythonPackage rec {
      name = "asyncio-irc-${version}";
      version = "2016-09-02";
      src = fetchFromGitHub {
        owner = "watchtower";
        repo = "asyncirc";
        rev = "5384d19";
        sha256 = "0xgzdvp0ig0im7r3vbqd3a9rzac0lkk2mvf7y4fw56p8k61df8nv";
      };
      propagatedBuildInputs = [ blinker ];
  };
in
buildPythonPackage rec {
    name = "shackie-${version}";
    version = "2017-04-24";
    propagatedBuildInputs = [
      asyncio-irc
      beautifulsoup4
      lxml
      pytz
      redis
      requests2
    ];
    src = fetchFromGitHub {
      owner = "shackspace";
      repo = "shackie";
      rev = "e717ec7";
      sha256 = "1ffbjm3x2xcyxl42hfsjs5xg1pm0xsprdi5if9zxa5ycqydmiw3l";
    };
}
