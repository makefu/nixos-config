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
      ../2configs/torrent.nix
      ../2configs/fs/sda-crypto-root.nix

      ../2configs/elchos/irc-token.nix
      ../2configs/elchos/log.nix
      ../2configs/elchos/search.nix
      ../2configs/elchos/stats.nix

    ];
  makefu.server.primary-itf = "enp8s0f0";
  krebs = {
      enable = true;
      build.host = config.krebs.hosts.fileleech;
  };
	# git clone https://github.com/makefu/docker-pyload
	# docker build .
  # docker run -d -v /var/lib/pyload:/opt/pyload/pyload-config -v /media/crypt0/pyload:/opt/pyload/Downloads --name pyload --restart=always -p 8112:8000 -P docker-pyload

  virtualisation.docker.enable = true; # for pyload
  networking.firewall.allowedTCPPorts =  [
    51412 # torrent
    8112  # rutorrent-web
    8113  # pyload
    8080  # sabnzbd
    9090  # sabnzbd-ssl
    655   # tinc
  ];
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
  makefu.snapraid = {
    enable = true;
    disks = map toMapper [ 0 1 2 3 4 5 6 ];
    parity = toMapper 7;
  };

  boot.loader.grub.device = rootDisk;

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "aacraid" "usb_storage" "usbhid" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # http://blog.hackathon.de/using-unsupported-sfp-modules-with-linux.html
  boot.extraModprobeConfig = ''
    options ixgbe allow_unsupported_sfp=1
  '';
}
