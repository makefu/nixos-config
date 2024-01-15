{ config, lib, ... }:
{
  sops.secrets."wbob-passwd-kiosk".neededForUsers = true;

  users.users.kiosk.hashedPasswordFile = config.sops.secrets."wbob-passwd-kiosk".path;
  # override the password for root@wbob to the kiosk password
  users.users.root.hashedPasswordFile = lib.mkForce config.sops.secrets."wbob-passwd-kiosk".path;
}
