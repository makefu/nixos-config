{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  cfg = config.makefu.forward-journal;

  out = {
    options.makefu.forward-journal = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "forward journal via syslog";
    src = mkOption {
      type = types.str;
      description = "syslog host identifier";
      default = config.networking.hostName;
    };
    dst = mkOption {
      type = types.str;
      description = "syslog host identifier";
      default = "";
    };
    proto = mkOption {
      type = types.str;
      default = "udp";
    };
    port = mkOption {
      type = types.int;
      description = "destination port";
      default = 514;
    };

  };

  imp = {
    services.syslog-ng = {
      enable = true;
      extraConfig = ''
        template t_remote { template("<$PRI>$DATE ${cfg.src} $PROGRAM[$PID]: $MSG\n"); };
        source s_all { system(); internal(); };
        destination d_loghost { udp("${cfg.dst}" port(${toString cfg.port}) template(t_remote)); };
        log { source(s_all); destination(d_loghost); };
      '';
    };
  };

in
out

