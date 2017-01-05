{ config, pkgs, lib, ... }:
let
  toMapper = id: "/media/crypt${builtins.toString id}";
  byid = dev: "/dev/disk/by-id/" + dev;
  keyFile = byid "usb-Intuix_DiskOnKey_09A07360336198F8-0:0";
  rootDisk = byid "ata-INTEL_SSDSA2M080G2GC_CVPO003402PB080BGN";
  rootPartition = rootDisk + "-part3";

	dataDisks =  let
		idpart = dev: byid  dev + "-part1";
	in [
		{ name = "crypt0"; device = idpart "scsi-1ATA_HUA722020ALA330_B9GDLJEF";}
	  {	name = "crypt1"; device = idpart "scsi-1ATA_HUA722020ALA330_B9GGWG8F";}
	  {	name = "crypt2"; device = idpart "scsi-1ATA_HUA722020ALA330_B9GH5NAF";}
	  {	name = "crypt3"; device = idpart "scsi-1ATA_HUA722020ALA330_B9GJWGDF";}
	  {	name = "crypt4"; device = idpart "scsi-1ATA_HUA722020ALA330_B9GKKXHF";}
	  {	name = "crypt5"; device = idpart "scsi-1ATA_HUA722020ALA330_B9GKKXVF";}
	  {	name = "crypt6"; device = idpart "scsi-1ATA_HUA722020ALA330_YAJJ8WRV";}
	  {	name = "crypt7"; device = idpart "scsi-1ATA_HUA722020ALA330_YBKTUS4F";} # parity
	];

  disks = [ { name = "luksroot"; device = rootPartition; } ] ++ dataDisks;
in {
    imports = [
      ../.
      ../2configs/tinc/retiolum.nix
      ../2configs/disable_v6.nix
      # ../2configs/torrent.nix
      ../2configs/fs/sda-crypto-root.nix

      ../2configs/elchos/irc-token.nix
      ../2configs/elchos/log.nix
      ../2configs/elchos/search.nix
      ../2configs/elchos/stats.nix
      ../2configs/stats-srv.nix

    ];
  systemd.services.grafana.serviceConfig.LimitNOFILE=10032;
  systemd.services.graphiteApi.serviceConfig.LimitNOFILE=10032;
  systemd.services.carbonCache.serviceConfig.LimitNOFILE=10032;
  makefu.server.primary-itf = "enp8s0f0";
  krebs = {
      enable = true;
      build.host = config.krebs.hosts.fileleech;
  };
	# git clone https://github.com/makefu/docker-pyload
	# docker build .
  # docker run -d -v /var/lib/pyload:/opt/pyload/pyload-config -v /media/crypt0/pyload:/opt/pyload/Downloads --name pyload --restart=always -p 8112:8000 -P docker-pyload

  virtualisation.docker.enable = true; # for pyload
  networking.firewall.allowPing = true;
  networking.firewall.logRefusedConnections = false;
  networking.firewall.allowedTCPPorts =  [
    51412 # torrent
    8112  # rutorrent-web
    8113  # pyload
    8080  # sabnzbd
    9090  # sabnzbd-ssl
    655   # tinc
  ];
  services.nginx.virtualHosts._download = {
    default = true;
    root = "/media/cryptX";
    extraConfig = ''
      autoindex on;
    '';
    basicAuth = import <secrets/kibana-auth.nix>;
  };
  networking.firewall.allowedUDPPorts = [
    655 # tinc
    51412 # torrent
  ];

  services.sabnzbd.enable = true;
  systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  boot.initrd.luks = {
    devices = let
      usbkey = name: device: {
        inherit name device keyFile;
        keyFileSize = 4096;
        allowDiscards = true;
      };
    in builtins.map (x: usbkey x.name x.device) disks;
  };
  environment.systemPackages = with pkgs;[ mergerfs ];

  fileSystems = let
    cryptMount = name:
      { "/media/${name}" = { device = "/dev/mapper/${name}"; fsType = "xfs"; };};
  in  cryptMount "crypt0"
		// cryptMount "crypt1"
		// cryptMount "crypt2"
		// cryptMount "crypt3"
		// cryptMount "crypt4"
		// cryptMount "crypt5"
		// cryptMount "crypt6"
		// cryptMount "crypt7"

    # this entry sometimes creates issues
    // { "/media/cryptX" = {
          device = (lib.concatMapStringsSep ":" (d: (toMapper d)) [ 0 1 2 3 4 5 6 ]);
          fsType = "mergerfs";
          noCheck = true;
          options = [ "defaults" "nofail" "allow_other" "nonempty" ]; };
        }

    ;
  users.users.download = {
  #  name = "download";
  #  home = "/media/cryptX/download";
  #  createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7betFnMWVeBYRhJ+2f0B5WbDdbpteIVg/BlyimXbx79R7lZ7nUq5GyMLrp7B00frUuA0su8oFFN3ODPJDstgBslBIP7kWPR2zW8NOXorrbFo3J2fKvlO77k6/wD5/M11m5nS01/aVJgAgMGLg2W12G7EMf5Wq75YsQJC/S9p8kMca589djMPRuQETu7fWq0t/Gmwq+2ELLL0csRK87LvybA92JYkAIneRnGzIlCguOXq0Vcq6pGQ1J1PfVEP76Do33X29l2hZc/+vR9ExW6s2g7fs5/5LDX9Wnq7+AEsxiEf4IOeL0hCG4/CGGCN23J+6cDrNKOP94AHO1si0O2lxFsxgNU2vdVWPNgSLottiUFBPPNEZFD++sZyutzH6PIz6D90hB2Q52X6WN9ZUtlDfQ91rHd+S2BhR6f4dAqiRDXlI5MNNDdoTT4S5R0wU/UrNwjiV/xiu/hWZYGQK7YgY4grFRblr378r8FqjLvumPDFMDLVa9eJKq1ad1x/GV5tZpsttzWj4nbixaKlZOg+TN2GHboujLx3bANz1Jqfvfto8UOeKTtA8pkb8E1PJPpBMOZcA7oHaqJrp6Vuf/SkmglHnQvGbi60OK3s61nuRmIcBiTXd+4qeAJpq1QyEDj3X/+hV0Gwz8rCo6JGkF1ETW37ZYvqU9rxNXjS+/Pfktw== jules@kvasir-2015-02-13"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDINUD+p2yrc9KoTbCiuYhdfLlRu/eNX6BftToSMLs8O9qWQORjgXbDn8M9iUWXCHzdUZ9sm6Rz8TMdEV0jZq/nB01zYnW4NhMrt+NGtrmGqDa+eYrRZ4G7Rx8AYzM/ZSwERKX10txAVugV44xswRxWvFbCedujjXyWsxelf1ngb+Hiy9/CPuWNYEhTZs/YuvNkupCui2BuKuoSivJAkLhGk5YqwwcllCr39YXa/tFJWsgoQNcB9hwpzfhFm6Cc7m5DhmTWSVhQHEWyaas8Lukmd4v+mRY+KZpuhbomCHWzkxqzdBun8SXiiAKlgem9rtBIgeTEfz9OtOfF3/6VfqE7 toerb@mittagspause ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0IP143FAHBHWjEEKGOnM8SSTIgNF1MJxGCMKaJvTHf momo@k2.local"
    ];
  };
  makefu.snapraid = {
    enable = true;
    disks = map toMapper [ 0 1 2 3 4 5 6 ];
    parity = toMapper 7;
  };
  networking.nameservers = [ "8.8.8.8" ];
  #networking.interfaces.enp6s0f0.ip4 = [{
  #    address = "151.217.173.20";
  #    prefixLength = 22;
  #}];
  #networking.defaultGateway = "151.217.172.1";
  networking.interfaces.enp8s0f1.ip4 = [{
      address = "192.168.126.1";
      prefixLength = 24;
  }];
  #interfaces.enp6s0f1.ip4 = [{
  #  address = external-ip;
  #  prefixLength = 22;
  #}];

  boot.loader.grub.device = rootDisk;

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "aacraid" "usb_storage" "usbhid" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # http://blog.hackathon.de/using-unsupported-sfp-modules-with-linux.html
  boot.extraModprobeConfig = ''
    options ixgbe allow_unsupported_sfp=1
  '';
}
