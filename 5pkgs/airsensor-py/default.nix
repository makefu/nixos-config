{ pkgs, fetchFromGitHub, ... }:
with pkgs.python3Packages;
buildPythonApplication rec {
    name = "airsensor-py-${version}";
    version = "1.0.0";
    propagatedBuildInputs = [
      pyusb
      click
    ];

    src = fetchFromGitHub {
      owner = "makefu";
      repo = "airsensor-py";
      rev = "1.0.0";
      sha256 = "1jpvvl965bg3ymvr58c433jyy0smczn65fnqsskxn7basznii5g8";
    };
}
