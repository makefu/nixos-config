{config,...}:{
  nix.settings.trusted-users = [ "nixBuild" ];
  users.users.nixBuild = {
    name = "nixBuild";
    isNormalUser = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      config.krebs.users.buildbotSlave.pubkeys
      ++ config.krebs.users.makefu-remote-builder.pubkeys;
  };
}
