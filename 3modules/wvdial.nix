{ config, lib, pkgs, ... }:
# from 17.03/nixos/modules/programs/wvdial.nix

with lib;

let

  configFile = ''
    [Dialer Defaults]
    PPPD PATH = ${pkgs.ppp}/sbin/pppd
    ${config.environment.wvdial.dialerDefaults}
  '';

  cfg = config.environment.wvdial;

in
{
  ###### interface

  options = {

    environment.wvdial = {

      dialerDefaults = mkOption {
        default = "";
        type = types.str;
        example = ''Init1 = AT+CGDCONT=1,"IP","internet.t-mobile"'';
        description = ''
          Contents of the "Dialer Defaults" section of
          <filename>/etc/wvdial.conf</filename>.
        '';
      };

      pppDefaults = mkOption {
        default = ''
          noipdefault
          usepeerdns
          defaultroute
          persist
          noauth
        '';
        type = types.str;
        description = "Default ppp settings for wvdial.";
      };

    };

  };

  ###### implementation

  config = mkIf (cfg.dialerDefaults != "") {

    environment = {

      etc =
      [
        { source = pkgs.writeText "wvdial.conf" configFile;
          target = "wvdial.conf";
        }
        { source = pkgs.writeText "wvdial" cfg.pppDefaults;
          target = "ppp/peers/wvdial";
        }
      ];

    };

  };

}
