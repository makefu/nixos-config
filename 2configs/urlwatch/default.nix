{ config, lib, ... }:

{
  krebs.urlwatch = {
    enable = true;
    mailto = config.krebs.users.makefu.mail;
    onCalendar = "*-*-* 05:00:00";
    hooksFile = ./hook.py;
    urls = [
      ## nixpkgs maintenance
      # github 
      ## No rate limit
      https://github.com/amadvance/snapraid/releases.atom
      https://github.com/radare/radare2/releases.atom
      https://github.com/ovh/python-ovh/releases.atom
      https://github.com/embray/d2to1/releases.atom
      https://github.com/Mic92/vicious/releases.atom
      https://github.com/embray/d2to1/releases.atom
      https://github.com/dorimanx/exfat-nofuse/releases.atom
      https://github.com/rapid7/metasploit-framework/releases.atom
      ## rate limited
      # https://api.github.com/repos/dorimanx/exfat-nofuse/commits
      # https://api.github.com/repos/mcepl/gen-oath-safe/commits
      https://api.github.com/repos/naim94a/udpt/commits
      https://api.github.com/repos/dirkvdb/ps3netsrv--/commits

      # pypi
      https://pypi.python.org/simple/bepasty/
      https://pypi.python.org/simple/xstatic/
      https://pypi.python.org/simple/devpi-client/
      # weird shit
      http://guest:derpi@cvs2svn.tigris.org/svn/cvs2svn/tags/
      http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/
      https://erdgeist.org/gitweb/opentracker/info/refs?service=git-upload-pack
      https://git.tasktools.org/TM/taskd/info/refs?service=git-upload-pack

      {
        url = https://newellrubbermaid.secure.force.com/dymopkb/articles/en_US/FAQ/Dymo-Drivers-and-Downloads/?l=en_US&c=Segment:Dymo&fs=Search&pn=1 ;
        filter = "grep:Software/Linux/dymo-cups-drivers";
      }
      # TODO: dymo cups
    ];
  };
}

