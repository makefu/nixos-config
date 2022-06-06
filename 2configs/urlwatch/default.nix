{ config, lib, ... }:

let
  grss = name: { #github rss feed
    url = "https://github.com/${name}/releases.atom";
    filter = "grepi:(<updated|<media.thumbnail|Continuous build|Travis CI build log:)";
  };
  lidl = url: {
    inherit url;
    filter = "element-by-id:articledetail,html2text";
  };
in {
  krebs.urlwatch = {
    enable = true;
    mailto = config.krebs.users.makefu.mail;
    onCalendar = "*-*-* 03,15:13:37";
    hooksFile = ./hook.py;
    urls = [
      ## nixpkgs maintenance
      # github 
      ## No rate limit

      ## rate limited
      # https://api.github.com/repos/mcepl/gen-oath-safe/commits
      https://api.github.com/repos/naim94a/udpt/commits
      https://api.github.com/repos/dirkvdb/ps3netsrv--/commits

      # pypi
      https://pypi.python.org/simple/bepasty/
      https://pypi.python.org/simple/devpi-client/
      https://pypi.python.org/simple/sqlalchemy_migrate/
      https://pypi.python.org/simple/xstatic/
      https://pypi.python.org/simple/pyserial/
      https://pypi.python.org/simple/semantic_version/
      # weird shit
      #{ url = "https://www.zigbee2mqtt.io/guide/adapters/";
      #  filter = "html2text";
      #}
      http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/
      https://erdgeist.org/gitweb/opentracker/info/refs?service=git-upload-pack

      http://www.iozone.org/src/current/

      #{
      #  url = https://newellrubbermaid.secure.force.com/dymopkb/articles/en_US/FAQ/Dymo-Drivers-and-Downloads/?l=en_US&c=Segment:Dymo&fs=Search&pn=1 ;
      #  filter = "grep:Software/Linux/dymo-cups-drivers";
      #}

      # shopping

      # TODO: dymo cups
    
    ] ++ map grss [
      "amadvance/snapraid"
      "radare/radare2"
      "ovh/python-ovh"
      "embray/d2to1"
      "vicious-widgets/vicious"
      "embray/d2to1"
      "rapid7/metasploit-framework"
      "GothenburgBitFactory/taskserver"
      "GothenburgBitFactory/taskwarrior"
      "mhagger/cvs2svn"
    ];
  };
}

