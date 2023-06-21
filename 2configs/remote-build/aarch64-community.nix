{ config, ... }: 
{
  sops.secrets."nixos-community" = {};
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "aarch64.nixos.community";
        maxJobs = 64;
        sshKey = config.sops.secrets."nixos-community".path;
        sshUser = "makefu";
        system = "aarch64-linux";
        supportedFeatures = [ "big-parallel" ];
      }
    ];
  };
}
