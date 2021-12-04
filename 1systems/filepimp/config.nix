{ config, pkgs, lib, ... }:
# nix-shell -p wol --run 'wol C8:CB:B8:CF:E4:DC --passwd=CA-FE-BA-BE-13-37'
let
  itf = config.makefu.server.primary-itf;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hw.nix
      <stockholm/makefu>
      <stockholm/makefu/2configs/home-manager>
      <stockholm/makefu/2configs/fs/single-partition-ext4.nix>
      <stockholm/makefu/2configs/smart-monitor.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/filepimp-share.nix>
    ];

  krebs.build.host = config.krebs.hosts.filepimp;

  networking.firewall.trustedInterfaces = [ itf ];
  networking.interfaces.${itf}.wakeOnLan = true;

}
