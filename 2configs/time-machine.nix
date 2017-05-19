let
  time-machine-path = "/media/crypt2/backup/time-machine/misa";
in {
	networking.firewall.allowedTCPPorts = [
    548 # netatalk
  ];

  services = {
    netatalk = {
      enable = true;

      volumes = {
        "misa-time-machine" = {
          "time machine" = "yes";
          path = time-machine-path;
          "valid users" = "misa";
        };
      };
    };

    avahi = {
      enable = true;
      nssmdns = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
