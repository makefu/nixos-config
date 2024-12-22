{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    aria2
    # mitmproxy
    binwalk
    dnsmasq
    iodine
    mtr
    nmap
    metasploit
    thc-hydra
    borgbackup
    ledger
    u3-tool
  ];
}
