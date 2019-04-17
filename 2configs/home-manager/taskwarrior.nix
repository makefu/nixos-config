{pkgs, ... }: 
let
  loc = "/home/makefu/.task";
in {
  state = [ "${loc}/keys" ];
  environment.shellAliases = {
    tshack = "task tags:shack";
    tkrebs = "task tags:krebs";
    thome = "task tags:home";
    t = "task project: ";
  };
  home-manager.users.makefu.programs.taskwarrior = {
    enable = true;
    dataLocation = loc;
    config = {
      default.command = "list";
      taskd = {
        server = "gum:53589";
        certificate = "${loc}/keys/public.crt";
        key = "${loc}/keys/private.key";
        ca = "${loc}/keys/ca.crt";
        credentials = "home/makefu/0e6c8146-1ddb-4906-9369-8f77e34cdf84";
      };
      context = {
        work = "tags:work";
        shack = "tags:shack";
        home = "tags:home";
      };
    };
  };
}
