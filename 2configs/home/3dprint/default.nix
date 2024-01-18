{ pkgs, ... }:
  {
  imports = [
    ./klipper.nix
    ./webcam.nix
    ./octoprint.nix
  ];

  # allow octoprint to access /dev/vchiq
  # also ensure that the webcam always comes up under the same name

}
