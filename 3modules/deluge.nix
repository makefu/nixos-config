{ config, lib, pkgs, ... }:
# based on <nixpkgs>/nixos/modules/services/torrent/deluge.nix
with config.krebs.lib;

let
  cfg_daemon = config.makefu.deluge;
  homedir = cfg_daemon.homedir;
  cfg_web = config.makefu.deluge.web;
  core_conf = pkgs.writeText "deluge-core-cfg" ''
    {
      "file": 1,
      "format": 1
    }${builtins.toJSON (recursiveUpdate default_core_cfg cfg_daemon.cfg)}
  '';

  default_core_cfg = {
    # ports and networking
    daemon_port = 58846; allow_remote = false;
    listen_ports = [ 0 0 ]; # from -> to, 0 -> random
    outgoing_ports = [ 0 0 ];
    random_port = true;
    random_outgoing_ports = true;
    listen_interface = "";
    # folders
    move_completed_path = homedir +"/complete"; move_completed = false;
    autoadd_location = homedir + "/watch"; autoadd_enable = true;
    download_location = homedir + "/data";
    torrentfiles_location = homedir + "/torrents"; copy_torrent_file = false; del_copy_torrent_file = false;
    plugins_location = homedir + "/.config/deluge/plugins"; enabled_plugins = [];
    geoip_db_location = pkgs.geolite-legacy + "/share/GeoIP/GeoIP.dat";
    queue_new_to_top = false;
    info_sent = 0;
    send_info = false;
    compact_allocation = false;
    # peer discovery, extras
    lsd = true;
    natpmp = true;
    utpex = false;
    dht = false;
    upnp = true;
    peer_tos = "0x08";
    # active torrents
    dont_count_slow_torrents = false;
    max_active_limit = -1;
    max_active_downloading = -1;
    max_active_seeding = -1;
    max_upload_slots_global = -1;
    # seeding
    share_ratio_limit = -1;
    seed_time_ratio_limit = -1;
    seed_time_limit = 180;
    stop_seed_at_ratio = false;
    remove_seed_at_ratio = false;
    stop_seed_ratio = 2;
    # speed and connections
    rate_limit_ip_overhead = true;
    ignore_limits_on_local_network = true;
    max_download_speed = -1;
    max_upload_speed = -1;
    max_upload_speed_per_torrent = -1;
    max_download_speed_per_torrent = -1;
    max_half_open_connections = -1;
    max_connections_global = -1;
    max_connections_per_second = -1;
    max_connections_per_torrent = -1;
    max_upload_slots_per_torrent = -1;
    enc_in_policy = 1;
    enc_prefer_rc4 = true;
    enc_level = 2;
    enc_out_policy = 1;
    cache_size = 8192;
    cache_expiry = 60;
    prioritize_first_last_pieces = false;
    auto_managed = true;
    proxies = {
      peer = {
        username = "";
        password = "";
        hostname = "";
        type = 0;
        port = 8080;
      };
      web_seed = {
        username = "";
        password = "";
        hostname = "";
        type = 0;
        port = 8080;
      };
      tracker = {
        username = "";
        password = "";
        hostname = "";
        type = 0;
        port = 8080;
      };
      dht = {
        username = "";
        password = "";
        hostname = "";
        type = 0;
        port = 8080;
      };
    };
    add_paused = false;
    new_release_check = false;
  };

  api = {
      enable = mkEnableOption "deluge daemon";

      cfg = mkOption {
        default = default_core_cfg;
        type = types.attrsOf types.unspecified;
        description = ''
          for full configuration see defaults
        '';
        example = {
          "daemon_port"= 58846;
          "download_location"= "/var/download";
        };
      };

      auth = mkOption {
        default = [];
        example = ["alice:MyC0mpL3xPass:10"];
        type = types.lines;
      };

      homedir = mkOption {
        default = "/var/lib/deluge";
        description = "Home directory of deluge user";
        type = types.str;
      };

      web = {
        enable = mkEnableOption "deluge web";
      };
    };
  imp = {

    systemd.services.deluged = {
      after = [ "network.target" ];
      description = "Deluge BitTorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.pythonPackages.deluge}/bin/deluged -d";
        ExecStartPre = pkgs.writeDash "deluged-init" ''
          mkdir -p ${homedir}/.config/deluge
          cp ${core_conf} ${homedir}/.config/deluge/core.conf
        '';
        Restart = "on-success";
        User = "deluge";
        Group = "deluge";
      };
    };

    systemd.services.delugeweb = mkIf cfg_web.enable {
      after = [ "network.target" ];
      description = "Deluge BitTorrent WebUI";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.pythonPackages.deluge}/bin/deluge --ui web";
      serviceConfig.User = "deluge";
      serviceConfig.Group = "deluge";
    };

    environment.systemPackages = [ pkgs.pythonPackages.deluge ];

    users.extraUsers.deluge = {
      group = "deluge";
      uid = config.ids.uids.deluge;
      home = cfg_daemon.homedir;
      createHome = true;
      description = "Deluge Daemon user";
    };

    users.extraGroups.deluge.gid = config.ids.gids.deluge;
  };
in {
  options.makefu.deluge = api;
  config = lib.mkIf cfg_daemon.enable imp;
}
