{config,...}:{
  nix.trustedUsers = [ "nixBuild" ];
  users.users.nixBuild = {
      name = "nixBuild";
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        config.krebs.users.buildbotSlave.pubkey
      ];
    };
}
