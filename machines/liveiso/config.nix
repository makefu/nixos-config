{ pkgs, modulesPath, ... }: {
  imports = [ 
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") 
    ../../2configs/core.nix

  ];
  # start sshd in any case
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  krebs.build.host.name = "liveiso"; 
}
