# Root disk for omo: disko GPT + LUKS (dm-crypt) + btrfs, Secure Boot via
# lanzaboote, clevis/tang unlocking (no TPM token).
#
# The LUKS key is the host key /etc/luks-keys/cryptroot (sops: omo-cryptroot),
# used for luksFormat initially and afterwards recovered at boot by letting
# the tang server (router, http://192.168.111.1:9090) decrypt
# /etc/clevis/cryptroot.jwe — see machines/omo/hw/clevis-tang.nix and
# README-omo-fde.md.
{ lib, ... }:
{
  imports = [
    ../../../2configs/security/secure-boot.nix
    ./clevis-tang.nix
  ];

  # systemd stage-1 is required: nixpkgs implements LUKS clevis unlocking as
  # a cryptsetup-clevis-cryptroot unit that decrypts the JWE into tmpfs before
  # systemd-cryptsetup@cryptroot runs (and rewrites that device's crypttab
  # keyFile to /clevis-cryptroot/decrypted).
  boot.initrd.systemd.enable = true;

  # AHCI/USB/NVMe + crypto modules needed in stage-1 (carried over from the
  # old GRUB/ext4 rootdisk setup).
  boot.initrd.availableKernelModules = [
    "ahci"
    "ohci_pci"
    "ehci_pci"
    "pata_atiixp"
    "firewire_ohci"
    "usb_storage"
    "usbhid"
    "raid456"
    "megaraid_sas"
    "cbc"
    "hmac"
    "sha256"
    "rng"
    "aes"
    "encrypted_keys"
    "xhci_hcd"
  ];

  # No TPM token / measured-boot cryptenroll here: unlocking goes through
  # clevis/tang (hw/clevis-tang.nix), not the TPM. Secure Boot stays enabled
  # for the signed-boot chain only.

  # The cryptroot boot.initrd.luks.devices entry (device, keyFile,
  # allowDiscards) and the `/` mount come from disko's luks/btrfs types below:
  # disko merges `settings` into the luks device config and emits fileSystems
  # from the filesystem content. mkForce drops the settings.keyFile from the
  # generated crypttab: at boot the key comes from the clevis unit below, not
  # from /etc/luks-keys (which lives inside the locked volume).
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/ata-KINGSTON_SUV400S37240G_50026B7772002946";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          crypt = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                # Used by disko at install time (luksFormat/luksOpen in the
                # kexec installer). Not usable at boot: see mkForce below.
                keyFile = "/etc/luks-keys/cryptroot";
                allowDiscards = true;
              };
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
                mountOptions = [ "discard" ];
              };
            };
          };
        };
      };
    };
  };

  # Boot-time crypttab keyfile: the clevis unit from nixpkgs' luksroot module
  # (generated because boot.initrd.clevis.devices.cryptroot is declared) runs
  #   clevis decrypt < /etc/clevis/cryptroot.jwe > /clevis-cryptroot/decrypted
  # before systemd-cryptsetup@cryptroot. Naming that file explicitly in the
  # crypttab (instead of leaving keyFile null and racing the parallel
  # cryptsetup-clevis unit / askpass loop) gives strict ordering:
  # systemd-cryptsetup waits for the file and never falls to an interactive
  # prompt on an unattended box.
  boot.initrd.luks.devices.cryptroot.keyFile = lib.mkForce "/clevis-cryptroot/decrypted";

  # ESP hygiene: UKIs are tens of MB on a 512M ESP.
  boot.lanzaboote.configurationLimit = lib.mkDefault 8;
}
