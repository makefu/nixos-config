{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let
  # returns dirname without / , used as disk name
  dname = dir: replaceChars ["/"] [""] (head (reverseList (splitString "/" dir)));
  snapraid-conf = ''
    # Disks
    ${concatMapStringsSep "\n" (d: "disk ${dname d} ${d}")  cfg.disks}
    # Parity
    ${optionalString (cfg.parity != "") "parity ${cfg.parity}/snapraid.parity"}

    # content on Disks
    ${optionalString cfg.contentOnDisks
      concatMapStringsSep "\n" (d: "content ${d}/snapraid.content")  cfg.disks}

    # content on Parity
    ${optionalString (cfg.contentOnParity && cfg.parity != "")
      "content ${cfg.parity}/snapraid.content"}
    # Default content file
    content ${cfg.defaultContentFile}

    # Extra Configuration
    ${cfg.extraConfig}
  '';
  cfg = config.makefu.snapraid;

  out = {
    options.makefu.snapraid = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "snapraid";

    timerConfig = mkOption {
      type = with types;attrsOf str;
      description = ''
        Start snapraid service
      '';
      default = {
        OnCalendar = "daily";
      };
    };
    disks = mkOption {
      type = with types;listOf str;
      description = ''
        Disks to protect. Each disk is a path to the mounted directory of the
        disk.
      '';
    };
    parity = mkOption {
      type = types.str;
      description = ''
        Folder to store parity file.
        Set to empty string if you want to configure the parity yourself in
        extraConfig.

        All extra parity files (2,3,z, etc...) should be configured via
        extraConfig.
      '';
    };
    contentOnDisks = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Store Content file on each Disk to protect.
        Set this to false if you do not want this behavior to apply.
      '';
    };
    contentOnParity = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Store Content file on parity Disk.
        Set this to false if you do not want this behavior to apply.
      '';
    };
    defaultContentFile = mkOption {
      type = types.str;
      default = "/var/cache/snapraid.content";
      description = ''
        Path to default content file
        Set to empty string if this content file should be written.
      '';
    };
    extraConfig = mkOption {
      type = types.string;
      default = "";
      description = ''
        Extra configuration to be appended to the snapraid conf file.
        You can configure extra Parity files as well as extra content files.
        See `man snapraid` for additional configuration
      '';
    };
  };

  imp = {
    environment.systemPackages = [
      # for scrubbing,fixing
      pkgs.snapraid
    ];
    environment.etc."snapraid.conf".text = snapraid-conf;
    systemd.timers.snapraid-sync = {
      description = "snapraid sync timer";
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.timerConfig;
    };
    systemd.services.snapraid-sync = {
      description = "Snapraid sync service";
      after = [ "network.target" "local-fs.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStartPre = pkgs.writeScript "Snapraid-sync-init" ''
          #! /bin/sh
          ${optionalString (cfg.defaultContentFile != "")
            "mkdir -p $(dirname ${cfg.defaultContentFile})"}
        '';
        ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
      };
    };
  };
in out
