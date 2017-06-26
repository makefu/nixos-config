{ pkgs, ... }:
{
  krebs.per-user.makefu.packages = [
    pkgs.taskwarrior
  ];

  environment.shellAliases = {
    tshack = "task project:shack";
    twork = "task project:soc";
    tpki = "task project:pki";
    tkrebs = "task project:krebs";
    t = "task project: ";
  };
}
