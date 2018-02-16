{ lib, ...}:
{
  ## Guest Extensions are currently broken
  imports = [
    (toString <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>)
  ];
  virtualisation.virtualbox.guest.enable = true;
  services.xserver.videoDrivers = lib.mkOverride 45 [ "virtualbox" "modesetting" ];

  fileSystems."/media/share" = {
    fsType = "vboxsf";
    device = "share";
    options = [ "rw" "uid=9001" "gid=9001" "nofail" ];
  };
  # virtualbox.baseImageSize = 35 * 1024;
}
