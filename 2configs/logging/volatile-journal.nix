# Keep the journal in RAM only.
#
# The journal is worthless after a crash anyway (it is a home server, logs are
# never forensically analysed) but it does cost ~1G of the small root/boot
# filesystem and a constant write load on the SSD. Storage=volatile puts it in
# /run/log/journal (tmpfs), capped at 512M and 7 days, whichever comes first.
#
# 2configs/core.nix already sets SystemMaxUse/RuntimeMaxUse; mkAfter appends our
# assignments after those so they win — systemd's config parser keeps the last
# assignment of a key.
{ lib, ... }:
{
  services.journald.storage = "volatile";
  services.journald.extraConfig = lib.mkAfter ''
    RuntimeMaxUse=512M
    MaxRetentionSec=7day
  '';
}
