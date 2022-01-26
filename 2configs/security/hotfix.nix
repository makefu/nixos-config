{ pkgs, lib,... }: {
  # https://github.com/berdav/CVE-2021-4034
  security.wrappers.pkexec.source = lib.mkForce (pkgs.writeText "pkexec" "");
}
