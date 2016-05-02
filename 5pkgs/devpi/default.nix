{ pkgs ? import <nixpkgs> {} }:
with pkgs.stdenv.lib;
let
  execnet14 = pkgs.python3Packages.buildPythonPackage rec {
    name = "execnet-1.4.1";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/source/e/execnet/${name}.tar.gz";
      sha256 = "1rpk1vyclhg911p3hql0m0nrpq7q7mysxnaaw6vs29cpa6kx8vgn";
    };

    propagatedBuildInputs = with pkgs.python3Packages;
      [ setuptools_scm apipkg ];
    meta = {
      description = "rapid multi-Python deployment";
      license = licenses.gpl2;
    };
  };

  devpi-web = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-web";
    version = "3.0.0";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/source/d/devpi-web/devpi-web-${version}.tar.gz";
      sha256 = "156abxyhj17a8cg38hpyr31qkjb61mb2kggsxij4p4xvy9jwkbwi";
    };

    propagatedBuildInputs = with pkgs.python3Packages;
      [ devpi-server pyramid_chameleon beautifulsoup4 Whoosh defusedxml ];

    meta = {
      homepage = https://bitbucket.org/hpk42/devpi;
      description = "a web view for devpi-server";
      license = licenses.mit;
      maintainers = with maintainers; [ makefu ];
    };
  };
  devpi-server = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-server";
    version = "3.0.2";

    # original postFixup adds "import sys; sys.argv[0] = 'devpi-server'" to
    # `.devpi-server-wrapped` which
    # results in "not existing devpi-server: 'devpi-server'"
    postFixup = "";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/source/d/devpi-server/devpi-server-${version}.tar.gz";
      sha256 = "14r1024i3x2pb72khyzvi56sh9smpdswmrbc88xvjxnalmzfn99d";
    };

    propagatedBuildInputs = with pkgs.python3Packages;
      [ devpi-common execnet14 itsdangerous pluggy waitress pyramid ];
    buildInputs = with pkgs.python3Packages; [ pytest beautifulsoup4 webtest ];

    meta = {
      homepage = https://bitbucket.org/hpk42/devpi;
      description = "Devpi Server";
      license = licenses.mit;
      maintainers = with maintainers; [ makefu ];
    };
  };

in {
  inherit devpi-server;
  devpi-web =  pkgs.python3.buildEnv.override {
      extraLibs = [ devpi-web devpi-server ];
    };
}
