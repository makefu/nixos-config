{
  imports = [
    <home-manager/nixos>
  ];
  home-manager.users.makefu = {
  };
  environment.variables = {
    GTK_DATA_PREFIX = "/run/current-system/sw";
  };
}
