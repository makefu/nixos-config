{
  nix.trustedUsers = [ "nixBuild" ];
  users.users.nixBuild = {
      name = "nixBuild";
      useDefaultShell = true;
      # TODO: put this somewhere else
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlhb0TIBW9RN9T8Is4YRIc1RjOg+cxbZCaDjbM4zxrX nixBuild"
      ];
    };
}
