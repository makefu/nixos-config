{ config, lib, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    urlwatch = with pkgs.pythonPackages; buildPythonPackage rec {
      name = "urlwatch-1.18";

      propagatedBuildInputs =  [ futures ];

      src = pkgs.fetchurl {
        url = "http://thp.io/2008/urlwatch/${name}.tar.gz";
        sha256 = "090qfgx249ks7103sap6w47f8302ix2k46wxhfssxwsqcqdl25vb";
      };

      postFixup = ''
        wrapProgram "$out/bin/urlwatch" --prefix "PYTHONPATH" : "$PYTHONPATH"
      '';
    };
  };
  krebs.urlwatch = {
    enable = true;
    mailto = config.krebs.users.makefu.mail;
    onCalendar = "*-*-* 05:00:00";
    urls = [
      ## nixpkgs maintenance
      https://api.github.com/repos/ovh/python-ovh/tags
      https://api.github.com/repos/embray/d2to1/tags
      http://git.sysphere.org/vicious/log/?qt=grep&q=Next+release
      https://pypi.python.org/simple/bepasty/
      https://pypi.python.org/simple/xstatic/
      http://guest:derpi@cvs2svn.tigris.org/svn/cvs2svn/tags/
      http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/
    ];
  };
}

