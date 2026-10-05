{ inputs, pkgs, config, ... }:
{
  imports = [
    inputs.podfetch.nixosModules.podfetch
  ];
  sops.secrets.podfetch = {
    owner = "download";
  };
  services.podfetch = {
    enable = true;
    package = inputs.podfetch.packages.${pkgs.system}.podfetchFull;
    user = "download";
    interval = "6h";
    settings = {
      output_dir = "/media/silent/music/kinder/podfetch";
      ads = {
        enabled = true;
        debug_dir = "/media/silent/music/kinder/podfetch_ads";
        engines = [
          # "silence"
          # "fingerprint"
          "asr"
          "neurallock"
          "sponsorblock-ml"
        ];
      };
    };
    settingsFile = config.sops.secrets.podfetch.path;
  };
}
