{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "gum.krebsco.de";
        maxJobs = 8;
        sshKey = toString <secrets/id_nixBuild>;
        sshUser = "nixBuild";
        system = "x86_64-linux";
        supportedFeatures = [ ];
      }
      {
        hostName = "gum.krebsco.de";
        maxJobs = 8;
        sshKey = toString <secrets/id_nixBuild>;
        sshUser = "nixBuild";
        system = "armv6l-linux";
        supportedFeatures = [ ];
      }
    ];
  };
}
