{ lib, ... }: {
  imports = [ 
    <stockholm/makefu/2configs/gui/snake-kiosk.nix> 
  ];
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = lib.mkForce false;
  # sound.enable = true;
  #hardware.pulseaudio = {
  #  enable = true;
  #  systemWide = true;
  #  tcp = {
  #    enable = true;
  #    anonymousClients.allowAll = true;
  #  };
  #};

  #users.users.makefu = {
  #  extraGroups = [ "pipewire" "audio" ];
  #};


  #services.xserver = {
  #  enable = true;
  #  # desktopManager.xterm.enable = true;
  #  desktopManager.xfce = {
  #    enable = true;
  #    noDesktop = true;
  #  };

  #  displayManager.autoLogin = {
  #    enable = true;
  #    user = "makefu";
  #  };
  #};    
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  systemWide = true;
  #  socketActivation = false;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  config.pipewire-pulse = {
  #    "pulse.properties"."server.address" = [ "unix:native" "tcp:4713" ];
  #  };

  #};


}
