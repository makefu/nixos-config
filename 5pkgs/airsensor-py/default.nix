{ pkgs, fetchFromGitHub, ... }:
with pkgs.python3Packages;
buildPythonApplication rec {
    name = "airsensor-py-${version}";
    version = "2017-04-24";
    propagatedBuildInputs = [
      pyusb
      click
    ];

    src = fetchFromGitHub {
      owner = "dfederschmidt";
      repo = "airsensor-py";
      rev = "c476918";
      sha256 = "0dc88vqxsgx20asbwfdjmz6yl6bvv65k0krvmmss3gcwxdgh9p2q";
    };
}
