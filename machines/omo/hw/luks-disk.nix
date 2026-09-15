# LUKS data disk for omo: whole-disk dm-crypt + XFS, unlocked in stage-1
# with clevis/tang (same scheme as the root disk, see rootdisk.nix +
# machines/omo/hw/clevis-tang.nix and README-omo-fde.md).
#
# Import via a fixed wrapper per disk (see omo/default.nix usage) so module
# dedup keeps the disko device and clevis declaration single.
#
# The keyfile is a REAL file on the host, not in git/the store: it wraps
# this disk's LUKS keyslot, lives on `/` (encrypted) at
# /etc/luks-keys/<name>, and only its tang-JWE form goes to the ESP:
# /etc/clevis/<name>.jwe (sops: omo-clevis-<name>.jwe). Before enabling a
# disk, create /etc/luks-keys/<name> on omo, `cryptsetup luksAddKey` it,
# build the JWE with clevis encrypt tang, and store it in sops.
{
  device,
  name,
  mountpoint,
  fsType ? "xfs",
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
        # Used by disko at format/open time (installer). At boot the key comes
        # from the clevis unit (/clevis-<name>/decrypted), forced below.
        keyFile = "/etc/luks-keys/${name}";
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

  boot.initrd.clevis.devices.${name}.secretFile = "/etc/clevis/${name}.jwe";
  boot.initrd.luks.devices.${name}.keyFile = lib.mkForce "/clevis-${name}/decrypted";
}
