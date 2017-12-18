{ pkgs, ...}:
let
  sshKey = (toString <secrets>) + "/id_nixBuild";
in {
  nix.distributedBuilds = true;
  # TODO: iterate over krebs.hosts
  nix.buildMachines = map ( hostName:
  {   inherit hostName sshKey;
      sshUser = "nixBuild";
      system = "x86_64-linux";
      maxJobs = 8;
  }) [ "hotdog.r" ];
  # puyak.r "wbob.r" "omo.r"  "gum.r" "latte.r"
}
