{ pkgs, config, ... }: 
let
  mainUser = config.krebs.build.user.name;
in {
  # Terminal
  home-manager.users.${mainUser} = {
    services.ssh-agent.enable = true;
    programs.rbw = {
      enable = true;
      settings.base_url = "bw.euer.krebsco.de";
      settings.email = "makefu@x";
    };
  };
}
