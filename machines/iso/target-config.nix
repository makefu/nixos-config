{ pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ./generated.nix ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.zfs.devNodes = "/dev"; # fixes some virtualmachine issues
  #boot.zfs.forceImportRoot = false;
  #boot.zfs.forceImportAll = false;
  boot.kernelParams = [
    "boot.shell_on_fail"
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCl3RTOHd5DLiVeUbUr/GSiKoRWknXQnbkIf+uNiFO+XxiqZVojPlumQUVhasY8UzDzj9tSDruUKXpjut50FhIO5UFAgsBeMJyoZbgY/+R+QKU00Q19+IiUtxeFol/9dCO+F4o937MC0OpAC10LbOXN/9SYIXueYk3pJxIycXwUqhYmyEqtDdVh9Rx32LBVqlBoXRHpNGPLiswV2qNe0b5p919IGcslzf1XoUzfE3a3yjk/XbWh/59xnl4V7Oe7+iQheFxOT6rFA30WYwEygs5As//ZYtxvnn0gA02gOnXJsNjOW9irlxOUeP7IOU6Ye3WRKFRR0+7PS+w8IJLag2xb" ];
  boot.tmpOnTmpfs = true;
  programs.bash.enableCompletion = true;
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=128M
  '';
      environment.systemPackages = [ (pkgs.writeScriptBin "network-setup" ''
        #!/bin/sh
        ip addr add  178.254.30.202/255.255.252.0 dev ens3
        ip route add default via 178.254.28.1
        echo nameserver 1.1.1.1 > /etc/resolv.conf
      '')];

  # minimal
  boot.supportedFilesystems = [ "zfs" ];
  programs.command-not-found.enable = false;
  time.timeZone = "Europe/Berlin";
  programs.ssh.startAgent = false;
  nix.useSandbox = true;
  users.mutableUsers = false;
  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = true;
  services.openssh.enable = true;
  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.use_tempaddr" = lib.mkDefault "2";
    "net.ipv6.conf.default.use_tempaddr" = lib.mkDefault "2";
  };
}
