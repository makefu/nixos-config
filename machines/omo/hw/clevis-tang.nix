# Clevis/tang unlock for omo's LUKS volumes (mirrors machines/x2/x230/tang.nix,
# but for dm-crypt instead of ZFS).
#
# The LUKS key is NOT unsealed from the TPM: the initrd boots the wired NIC,
# asks the tang server (router, 192.168.111.1:9090) to decrypt a pre-created
# JWE, and feeds the recovered keyfile to cryptsetup. nixpkgs' luksroot module
# turns `boot.initrd.clevis.devices.cryptroot` into a
# `cryptsetup-clevis-cryptroot` unit that runs
#   clevis decrypt < /etc/clevis/cryptroot.jwe > /clevis-cryptroot/decrypted
# before systemd-cryptsetup@cryptroot, and rewrites that device's crypttab
# keyFile to /clevis-cryptroot/decrypted. See README-omo-fde.md.
#
# The JWE source path is a live file on the host (string, not a store path), so
# the tang-sealed secret never enters git or the nix store at eval time; its
# canonical copy is the sops secret `omo-cryptroot.jwe` (a JWE is public-key
# ciphertext, but we keep it in sops alongside the keyfile it wraps).
{
  boot.initrd.clevis = {
    enable = true;
    useTang = true;
    # <name> must match boot.initrd.luks.devices.<name> (= disko luks name);
    # baked into the initrd as /etc/clevis/cryptroot.jwe by
    # append-initrd-secrets at every bootloader update.
    devices.cryptroot.secretFile = "/etc/clevis/cryptroot.jwe";
  };

  # Stage-1 networking: tang is only useful if the initrd can reach it.
  # enp2s0 is the physical port; in stage-2 it becomes a br0 bridge port, but
  # in the initrd it gets DHCP directly with the same permanent MAC, so the
  # router hands out omo's reserved lease (192.168.111.11) either way.
  boot.initrd.systemd.network = {
    enable = true;
    networks."10-enp2s0" = {
      matchConfig.Name = "enp2s0";
      networkConfig.DHCP = "yes";
    };
  };

  # Wired NIC drivers for stage-1. Verify on omo with
  #   readlink /sys/class/net/enp2s0/device/driver
  # and extend if the box lands on another chipset.
  boot.initrd.availableKernelModules = [
    "e1000"
    "e1000e"
    "igb"
    "igc"
    "r8169"
  ];
}
