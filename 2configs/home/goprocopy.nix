{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.goprocopy.nixosModules.default ];

  sops.secrets."omo-goprocopy-env" = {
    restartUnits = [ "goprocopy.service" ];
  };

  services.goprocopy = {
    enable = true;
    package = inputs.goprocopy.packages.${pkgs.system}.goprocopy;
    destination = "/media/cryptX/photos/gopro";
    # GOPRO_NTFY_URL (with basic-auth userinfo) comes from the env-file secret
    ntfyUrl = "";
    haUrl = "http://hass.lan";
    sonosEntity = "media_player.buro";
    environmentFiles = [ config.sops.secrets."omo-goprocopy-env".path ];
  };

  # /media/cryptX is the mergerfs-over-LUKS mount of machines/omo/hw/omo;
  # never run the import against the rootfs placeholder.
  systemd.services.goprocopy = {
    requires = [ "media-cryptX.mount" ];
    after = [ "media-cryptX.mount" ];
  };
}
