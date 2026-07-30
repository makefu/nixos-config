{ config, pkgs, lib, inputs, ... }:
# diyHue (Philips Hue Bridge emulator) needs to look like its own physical
# device on the LAN: it must pull its own DHCP lease, answer SSDP/mDNS
# discovery broadcasts and own tcp/80 + tcp/443 (Hue apps hard-expect those
# ports). omo already occupies :80 (nginx) and :443, so diyHue cannot share the
# host's network stack. It runs in a NixOS container whose veth is enslaved to
# the host bridge br0, giving the container a real LAN presence with its own MAC
# and DHCP address, while the host also sits on br0 so Home Assistant on omo
# stays reachable from the emulator (macvlan would have blocked host<->container).
#
# The br0 bridge itself is defined in machines/omo/networking.nix.
let
  # Stable, locally-administered MAC. Pins both the container veth (=> stable
  # DHCP lease) and diyHue's derived bridge serial / TLS cert. Keep this fixed.
  mac = "02:00:00:CA:FE:01";
  # mac = "4A:F8:0E:F3:7A:83";

  diyhuePkg = inputs.diyhue.packages.${pkgs.stdenv.hostPlatform.system}.diyhue;
in
{
  # --- diyHue container, one veth on the LAN bridge (br0 from networking.nix) ---
  containers.hue = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localMacAddress = mac;

    config = { pkgs, lib, ... }: {
      imports = [ inputs.diyhue.nixosModules.diyhue ];

      # The module defaults services.diyhue.package to pkgs.diyhue; supply it
      # from the flake (same nixpkgs, same arch as the host).
      nixpkgs.overlays = [ (final: prev: { diyhue = diyhuePkg; }) ];

      # Container has its own networkd + resolved and gets DNS from the DHCP
      # lease, so it must not inherit the host's /etc/resolv.conf (that combo
      # trips a nixos-containers assertion).
      networking.useHostResolvConf = false;

      # Container uses networkd (matches the host); DHCP on the container veth.
      # nixos-containers with hostBridge names the container-side interface
      # eth0 (host side is vb-hue). Its MAC is a stable per-container hash, so
      # the DHCP lease is stable without pinning it here.
      systemd.network = {
        enable = true;
        networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.DHCP = "yes";
        };
      };

      services.diyhue = {
        enable = true;
        inherit mac;
        # Container owns its LAN IP outright: bind everything, serve 80/443
        # directly, let the module open the Hue discovery UDP ports.
        openFirewall = true;
      };

      system.stateVersion = "24.05";
    };
  };
}
