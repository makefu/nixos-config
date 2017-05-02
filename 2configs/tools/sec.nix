{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs; [
    aria2
    # mitmproxy
    pythonPackages.binwalk-full
    dnsmasq
    iodine
    mtr
    nmap
    msf
    thc-hydra
    borgbackup
    ledger
  ];
}
