{ config, lib, ... }:

{
  krebs.urlwatch = {
    enable = true;
    mailto = config.krebs.users.makefu.mail;
    onCalendar = "*-*-* 05:00:00";
    hooksFile = ./hook.py;
    urls = [
      ## nixpkgs maintenance
      https://api.github.com/repos/ovh/python-ovh/tags
      https://api.github.com/repos/embray/d2to1/tags
      https://api.github.com/repos/Mic92/vicious/tags
      https://pypi.python.org/simple/bepasty/
      https://pypi.python.org/simple/xstatic/
      https://pypi.python.org/simple/devpi-client/
      http://guest:derpi@cvs2svn.tigris.org/svn/cvs2svn/tags/
      http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/
      https://github.com/amadvance/snapraid/releases.atom
      https://erdgeist.org/gitweb/opentracker/info/refs?service=git-upload-pack
      https://api.github.com/repos/embray/d2to1/tags
      https://api.github.com/repos/dorimanx/exfat-nofuse/commits
      https://api.github.com/repos/dorimanx/exfat-nofuse/tags
      https://api.github.com/repos/radare/radare2/tags
      https://api.github.com/repos/rapid7/metasploit-framework/tags
      https://api.github.com/repos/mcepl/gen-oath-safe/commits
      https://api.github.com/repos/naim94a/udpt/commits
      https://git.tasktools.org/TM/taskd/info/refs?service=git-upload-pack
      https://api.github.com/repos/dirkvdb/ps3netsrv--/commits
      # TODO: dymo cups

    ];
  };
}

