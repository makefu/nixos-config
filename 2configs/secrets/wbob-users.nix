{ config, lib, ... }:
{
  sops.secrets."passwd/kiosk".neededForUsers = true;

  users.users.kiosk.passwordFile = config.sops.secrets."passwd/kiosk".path;
  # override the password for root@wbob to the kiosk password
  users.users.root.passwordFile = lib.mkForce config.sops.secrets."passwd/kiosk".path;
}
