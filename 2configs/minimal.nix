{ lib, pkgs, config, ... }:
# minimal subset of sane configuration for stockholm
{
  # nobody needs this
  programs.command-not-found.enable = false;

  # the only true timezone (even after the the removal of DST)
  time.timeZone = "Europe/Berlin";

  networking.hostName = lib.mkIf (lib.hasAttr "host" config.krebs.build) config.krebs.build.host.name;

  # we use gpg if necessary (or nothing at all)
  programs.ssh.startAgent = false;

  # all boxes look the same
  nix.settings.sandbox = true;
  nix.settings.cores = 0; # until https://github.com/NixOS/nixpkgs/pull/50440 is in stable
  # we configure users via nix
  users.mutableUsers = false;

  # sane firewalling
  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = true;

  # openssh all the way down
  services.openssh.enable = true;

  # we use stockholm via populate
  nix.nixPath = [ "/var/src" ];

  environment.variables = let
    ca-bundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  in {
    NIX_PATH = lib.mkForce "/var/src";
    EDITOR = lib.mkForce "vim";
    CURL_CA_BUNDLE = ca-bundle;
    GIT_SSL_CAINFO = ca-bundle;
    SSL_CERT_FILE  = ca-bundle;
  };

  programs.bash = {
    interactiveShellInit = ''
      HISTCONTROL='erasedups:ignorespace'
      HISTSIZE=900001
      HISTFILESIZE=$HISTSIZE

      shopt -s checkhash
      shopt -s histappend histreedit histverify
      shopt -s no_empty_cmd_completion
      '';

    promptInit = ''
      case $UID in
         0) PS1='\[\e[1;31m\]\w\[\e[0m\] ' ;;
      9001) PS1='\[\e[1;32m\]\w\[\e[0m\] ' ;;
         *) PS1='\[\e[1;35m\]\u \[\e[1;32m\]\w\[\e[0m\] ' ;;
      esac
      if test -n "$SSH_CLIENT"; then
        PS1='\[\033[35m\]\h'" $PS1"
      fi
      '';
  };

  # trust the cool guys
  networking.timeServers = [
    "pool.ntp.org"
    "time.nist.gov"
  ];

  # the only locale you will ever need
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console.keyMap = "us";

  # suppress chrome autit event messages
  security.audit.rules = [ "-a task,never" ];

  # Enable IPv6 Privacy Extensions
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.use_tempaddr" = lib.mkDefault "2";
    "net.ipv6.conf.default.use_tempaddr" = lib.mkDefault "2";
  };

}
