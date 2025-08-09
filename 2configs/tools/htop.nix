{ pkgs, config, ... }: 
let
  mainUser = config.krebs.build.user.name;
in {
  home-manager.users.${mainUser} = {
    programs.htop = {
      enable = true;
      settings = {
        show_cpu_temperature = 1;
        column_meters_0= "LeftCPUs Memory Swap";
        column_meter_modes_0="0 0 0";
        column_meters_1 = "RightCPUs Tasks LoadAverage Uptime NetworkIO";
        column_meter_modes_1="0 0 0 0 0";
      };
    };
  };
}
