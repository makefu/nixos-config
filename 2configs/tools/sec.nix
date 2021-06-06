{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    aria2
    # mitmproxy
    python3Packages.binwalk-full
    dnsmasq
    iodine
    mtr
    nmap
    msf
    thc-hydra
    borgbackup
    ledger
    u3-tool
  ];
}
