{
  networking.wireless = {
    enable = true;
    networks = import <secrets/wifi.nix>;
  };
}
