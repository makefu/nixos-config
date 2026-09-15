# Root disk for omo: disko GPT + LUKS (dm-crypt) + btrfs, Secure Boot via
# lanzaboote, TPM2-unsealed unlocking.
#
# Stage-1 crypttab passes both the keyfile and tpm2-device=auto: the keyfile
# (copied into the initrd via boot.initrd.secrets) always works; once the TPM
# token is enrolled, systemd-cryptsetup activates the token with the keyfile
# as key material, so the TPM also unlocks the volume. The first enrollment
# must happen while the volume is unlocked (auto-cryptenroll service) — see
# README-omo-fde.md.
{ config, lib, ... }:
{
  imports = [ ../../../2configs/security/secure-boot.nix ];

  # systemd stage-1 is required for crypttab-based unlocking with TPM2 tokens
  # (the old scripted initrd path ignores crypttabExtraOpts).
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;

  # Keyfile source is the REAL file /etc/luks-keys/cryptroot on the host
  # (a string, not a store path — the key never enters git or the nix store
  # at eval time). `append-initrd-secrets` cp -a's it into the initrd at
  # every bootloader update, so the file must exist at that path when
  # nixos-install/switch first runs — see README-omo-fde.md for how
  # nixos-anywhere places it (--disk-encryption-keys + --extra-files).
  # It persists in /etc across switches, so later rebuilds on omo work too.
  # No environment.etc entry: that would symlink /etc/luks-keys and clobber
  # the real file at activation.
  boot.initrd.secrets = {
    "/etc/luks-keys/cryptroot" = "/etc/luks-keys/cryptroot";
  };

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

  # Measured boot: lock PCR4 (boot loader / kernel command line) and PCR7
  # (Secure Boot policy, incl. the stage-1 cryptsetup unit + keyfile via
  # systemd-pcrlock). Once Secure Boot is on, resealed automatically at boot.
  #
  # auto-cryptenroll seals the LUKS TPM token with the pcrlock policy; only
  # 4+7 are measured here, so firmware/code (PCR0/2) is excluded on purpose —
  # a BIOS update must not brick the unlock.
  boot.lanzaboote.measuredBoot = {
    enable = true;
    pcrs = [ 4 7 ];
    autoCryptenroll = {
      enable = true;
      device = "/dev/disk/by-partlabel/disk-main-crypt";
      autoReboot = false;
    };
  };

  # The cryptroot boot.initrd.luks.devices entry (device, keyFile,
  # allowDiscards, tpm2-device=auto) and the `/` mount come from disko's
  # luks/btrfs types below: disko merges `settings` into the luks device
  # config and emits fileSystems from the filesystem content.
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
                keyFile = "/etc/luks-keys/cryptroot";
                allowDiscards = true;
                crypttabExtraOpts = [ "tpm2-device=auto" ];
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

  # lanzaboote asserts <=8: systemd-pcrlock can only pin that many ESP
  # generations when measured boot is on.
  boot.lanzaboote.configurationLimit = lib.mkDefault 8;

  # Upstream auto-cryptenroll unlocks with `--unlock-tpm2-device=auto`, which
  # needs an *existing* TPM token — so it fails on the first enroll (fresh
  # volume has no token; systemd's prepare_luks has no keyfile fallback,
  # src/cryptenroll/cryptenroll.c prepare_luks()). Unlock with the keyfile
  # instead: works before and after enrollment alike.
  systemd.services.auto-cryptenroll.serviceConfig.ExecStart = lib.mkForce [
    "${config.boot.loader.external.installHook}"
    ''
      systemd-cryptenroll \
        --wipe-slot=tpm2 \
        --tpm2-device=auto \
        --unlock-key-file=/etc/luks-keys/cryptroot \
        --tpm2-pcrlock=/var/lib/systemd/pcrlock.json \
        /dev/disk/by-partlabel/disk-main-crypt
    ''
  ];
}
