# LUKS data disk for omo: whole-disk dm-crypt + XFS, unlocked in stage-1
# with clevis/tang exactly like the root disk (see rootdisk.nix +
# machines/omo/hw/clevis-tang.nix and README-omo-fde.md).
#
# Import via a fixed wrapper per disk (see omo/default.nix usage) so module
# dedup keeps the disko device and clevis declaration single.
#
# All data disks share ONE keyfile, /etc/luks-keys/cryptroot (sops:
# omo-cryptroot), and its single tang JWE /etc/clevis/cryptext.jwe (sops:
# omo-cryptroot.jwe). The nixpkgs clevis module copies the JWE into the initrd
# under each declared device name (/etc/clevis/<name>.jwe), so one source file
# serves every volume; the matching cryptsetup-clevis-<name> unit decrypts it
# to /clevis-<name>/decrypted for cryptsetup.
#
# `nofail` keeps a failed decrypt (tang down, disk dead, keyslot missing)
# from breaking boot: the volume is still attempted, but cryptsetup.target
# does not wait or fail, and `headless=1` forbids an interactive prompt that
# would hang an unattended box. Downstream mounts (XFS, mergerfs, snapraid)
# are nofail/weak too.
{
  device,
  name,
  mountpoint,
  fsType ? "xfs",
  keyName ? "cryptroot",
}:
{ lib, ... }:
{
  disko.devices.disk.${name} = {
    type = "disk";
    inherit device;
    content = {
      type = "luks";
      inherit name;
      settings = {
        # Used by disko only at format/open time (installer). At boot the key
        # comes from the clevis unit (/clevis-<name>/decrypted), forced below.
        keyFile = "/etc/luks-keys/${keyName}";
        allowDiscards = true;
      };
      content = {
        type = "filesystem";
        format = fsType;
        inherit mountpoint;
        mountOptions = [ "nofail" ];
      };
    };
  };

  boot.initrd.clevis.devices.${name}.secretFile = "/etc/clevis/${keyName}.jwe";
  boot.initrd.luks.devices.${name} = {
    keyFile = lib.mkForce "/clevis-${name}/decrypted";
    crypttabExtraOpts = lib.mkForce [
      "nofail"
      "headless=1"
    ];
  };
}
