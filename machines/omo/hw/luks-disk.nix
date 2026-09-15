# LUKS data disk for omo: whole-disk dm-crypt + XFS, unlocked in stage-1
# with a keyfile at /etc/luks-keys/<name> and (once enrolled) the TPM2 token.
#
# Import via a fixed wrapper per disk (see omo/default.nix usage) so module
# dedup keeps the disko device and secret declaration single.
#
# The keyfile is a REAL file on the host, not in git/the store:
# boot.initrd.secrets uses the same path as source (string, not store path).
# Before enabling a disk, create /etc/luks-keys/<name> on omo and
# `cryptsetup luksAddKey` it (or luksFormat fresh) — see README-omo-fde.md.
{
  device,
  name,
  mountpoint,
  fsType ? "xfs",
}:
{
  disko.devices.disk.${name} = {
    type = "disk";
    inherit device;
    content = {
      type = "luks";
      inherit name;
      settings = {
        keyFile = "/etc/luks-keys/${name}";
        allowDiscards = true;
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
      content = {
        type = "filesystem";
        format = fsType;
        inherit mountpoint;
        mountOptions = [ "nofail" ];
      };
    };
  };

  boot.initrd.secrets."/etc/luks-keys/${name}" = "/etc/luks-keys/${name}";
}
