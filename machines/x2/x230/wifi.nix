{ config, lib, pkgs, ... }:
# Post-boot wifi fallback. Earlier rev ran wpa_supplicant in initrd so
# clevis/tang could reach the LAN before rpool unlock — that wired the PSK
# into the unencrypted ESP and grew the initramfs. Wifi now lives in
# userspace; initrd unlock relies on wired. NetworkManager owns wlan0.
#
# Provision the PSK as a clan secret (env-file payload — NM substitutes
# `$WIFI_PSK` from environmentFiles):
#
#   printf 'WIFI_PSK=%s\n' '<hex psk>' \
#     | clan secrets set --machine x2 --user makefu x2-wifi-psk
let
  ssid = "127.0.0.1";
in
{
  imports = [
    ../../../2configs/hw/network-manager.nix
  ];

  sops.secrets."x2-wifi-psk" = { };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets."x2-wifi-psk".path ];
    profiles.${ssid} = {
      connection = {
        id = ssid;
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        mode = "infrastructure";
        ssid = ssid;
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PSK";
      };
      ipv4.method = "auto";
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
    };
  };
}
