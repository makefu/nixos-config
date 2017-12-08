{ pkgs ? import <nixpkgs> {} }:
with pkgs.stdenv.lib;
let

  readme-renderer = pkgs.python3Packages.buildPythonPackage rec {
    name = "readme_renderer";
    version = "0.7.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/readme_renderer/readme_renderer-${version}.tar.gz";
      sha256 = "1kh9ggff8m9sdgr631vf2n4k97h4z1871vay6qgk3ydy3rd856ak";
    };
    buildInputs = with pkgs.python3Packages; [ pytest ];
    propagatedBuildInputs = with pkgs.python3Packages; [ docutils bleach pygments ];

  };
  devpi-web = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-web";
    version = "3.1.1";


    src = pkgs.fetchurl {
      url = "mirror://pypi/d/devpi-web/devpi-web-${version}.tar.gz";
      sha256 = "0bvqv52jmasfm4sdyccwsgvk9a663d3grj7zjw8r9x7xm7l3svqv";
    };

    propagatedBuildInputs = with pkgs.python3Packages;
      [ pkgs.devpi-server pyramid_chameleon beautifulsoup4 defusedxml readme-renderer ];

    meta = {
      homepage = https://bitbucket.org/hpk42/devpi;
      description = "a web view for devpi-server";
      license = licenses.mit;
      maintainers = with maintainers; [ makefu ];
    };
  };

in {
  devpi-web =  pkgs.python3.buildEnv.override {
      extraLibs = [ devpi-web devpi-server ];
    };
}
