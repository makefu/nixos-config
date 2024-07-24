{ pkgs, config, ... }:
{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    # storageDriver = "devicemapper";
  };

  #networking.nat = {
  #  enable = true;
  #  internalInterfaces = [ "ve-+" ];
  #  externalInterface = "enp2s0";
  #};

  environment.systemPackages = with pkgs;[
    podman
    podman-tui
    podman-compose
  ];

  users.users.${config.krebs.build.user.name}.extraGroups = [ "podman" ];
}
