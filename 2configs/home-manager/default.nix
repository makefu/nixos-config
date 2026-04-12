{ self, inputs, ... }:
{
  imports = [ ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.makefu = {
      home.stateVersion = "19.03";
    };
    extraSpecialArgs = { inherit self inputs; };
  };

  environment.variables = {
    GTK_DATA_PREFIX = "/run/current-system/sw";
  };
}
