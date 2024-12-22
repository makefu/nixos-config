{ config, pkgs, ... }: with pkgs.stockholm.lib; let
  mk_peers = mapAttrs (n: v: { id = v.syncthing.id; });

  all_peers = filterAttrs (n: v: v.syncthing.id != null) config.krebs.hosts;
  used_peer_names = unique (flatten (mapAttrsToList (n: v: v.devices) config.services.syncthing.settings.folders));
  used_peers = filterAttrs (n: v: elem n used_peer_names) all_peers;

in {
  services.syncthing = {
    enable = true;
    configDir = "/var/lib/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    openDefaultPorts  = true;
    settings =  {
      devices = (mk_peers used_peers) //  {
        makefu-phone.id = "YP57S7C-4U7PTEV-7PNVREJ-574YUTC-XMZ6TH5-P7UL5IJ-VYGW7GV-Z6QYOQR";
        makefu-ebook.id = "RRNPQ7N-BUGZUKX-EU7VSDJ-Z5BTW33-55DOSF4-RJXWV7W-BL7TUHT-TV7EJQN";
        makefu-tablet-medion.id = "RRJGBJC-B4WHTRY-MGFWEZU-JLTQWM6-M5N3CWM-MDSVVYC-LP67NM2-B3ZK4AI";
        gum.id = "463N4HM-LFU3ARM-M7YU6O5-7FAVRIZ-WUOX5FN-C6A3XLZ-UCDUXQ5-2MVXDA6";
        x.id = "ETMOWBT-XOYB7LJ-J4OKD7U-WHBEAP5-MPAHKXM-O4GGRKM-WERF7R4-MRS7EAU"; # override config for x
        omo.id = "Y5OTK3S-JOJLAUU-KTBXKUW-M7S5UEQ-MMQPUK2-7CXO5V6-NOUDLKP-PRGAFAK";
      };
      key = config.sops.secrets."${config.clan.core.machineName}-syncthing.key".path;
      cert = config.sops.secrets."${config.clan.core.machineName}-syncthing.cert".path;
    };
  };
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
}
