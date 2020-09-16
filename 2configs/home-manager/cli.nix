{pkgs, ... }: {
  imports = [ ./zsh.nix ];
  home-manager.users.makefu = {
    programs.direnv = {
      enableZshIntegration = true;
    };
  };
  services.udev.packages = [
    pkgs.libu2f-host
    pkgs.yubikey-personalization
  ];
}
