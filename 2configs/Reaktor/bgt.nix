{ pkgs, ... }:
{
  krebs.Reaktor.reaktor-bgt = {
    nickname = "Reaktor|bgt";
    workdir = "/var/lib/Reaktor/bgt";
    channels = [ "#binaergewitter" ];
    plugins = with pkgs.ReaktorPlugins;
    [ titlebot
      # stockholm-issue
      nixos-version
      # shack-correct
      # sed-plugin
      random-emoji ];
  };
}
