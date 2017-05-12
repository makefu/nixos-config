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
  devpi-client = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-client";
    version = "2.7.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/devpi-client/devpi-client-${version}.tar.gz";
      sha256 = "0z7vaf0a66n82mz0vx122pbynjvkhp2mjf9lskgyv09y3bxzzpj3";
    };
    patches = [ ./py3-fix-encoding.patch ];
    buildInputs = with pkgs.python3Packages; [ tox check-manifest pkginfo ];
    propagatedBuildInputs = with pkgs.python3Packages; [ devpi-common py ];
  };
  devpi-web = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-web";
    version = "3.1.1";


    src = pkgs.fetchurl {
      url = "mirror://pypi/d/devpi-web/devpi-web-${version}.tar.gz";
      sha256 = "0bvqv52jmasfm4sdyccwsgvk9a663d3grj7zjw8r9x7xm7l3svqv";
    };

    propagatedBuildInputs = with pkgs.python3Packages;
      [ devpi-server pyramid_chameleon beautifulsoup4 defusedxml readme-renderer ];

    meta = {
      homepage = https://bitbucket.org/hpk42/devpi;
      description = "a web view for devpi-server";
      license = licenses.mit;
      maintainers = with maintainers; [ makefu ];
    };
  };

  devpi-common-3 = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-common";
    version = "3.0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/devpi-common/devpi-common-${version}.tar.gz";
      sha256 = "0l3a7iyk596x6pvzg7604lzzi012qszr804fqn6f517zcy1xz23j";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [ requests py ];

    meta = {
      homepage = https://bitbucket.org/hpk42/devpi;
      description = "Utilities jointly used by devpi-server and devpi-client";
      license = licenses.mit;
      maintainers = with maintainers; [ lewo makefu ];
    };
  };

  devpi-server = pkgs.python3Packages.buildPythonPackage rec {
    name = "devpi-server";
    version = "4.1.1";

    # original postFixup adds "import sys; sys.argv[0] = 'devpi-server'" to
    # `.devpi-server-wrapped` which
    # results in "not existing devpi-server: 'devpi-server'"
    postFixup = "";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/devpi-server/devpi-server-${version}.tar.gz";
      sha256 = "1icbn1nw6w0sc5150fr69rlhs0j5ldnnxfzl2qabq2wi0dbar8hf";
    };

    propagatedBuildInputs = with pkgs.python3Packages;
      [ devpi-common-3 execnet itsdangerous pluggy waitress pyramid ];
    buildInputs = with pkgs.python3Packages; [ pytest beautifulsoup4 webtest ];

    meta = {
      homepage = https://bitbucket.org/hpk42/devpi;
      description = "Devpi Server";
      license = licenses.mit;
      maintainers = with maintainers; [ makefu ];
    };
  };

in {
  inherit devpi-server devpi-client;
  devpi-web =  pkgs.python3.buildEnv.override {
      extraLibs = [ devpi-web devpi-server ];
    };
}
