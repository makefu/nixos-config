{config,...}:{
  nix.trustedUsers = [ "nixBuild" ];
  users.users.nixBuild = {
    name = "nixBuild";
    isNormalUser = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      config.krebs.users.buildbotSlave.pubkey
      config.krebs.users.makefu-remote-builder.pubkey
    ];
  };
}
