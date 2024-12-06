{ pkgs, modulesPath, ... }: {
  imports = [ 
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") 
    ../../2configs

  ];
  # start sshd in any case
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
 
}
