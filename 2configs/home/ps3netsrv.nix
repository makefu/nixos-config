{ pkgs, ... }:
{
        makefu.ps3netsrv = {
          enable = true;
          servedir = "/media/cryptX/emu/ps3";
        };
        users.users.makefu.packages = [ pkgs.pkgrename ];
      }
