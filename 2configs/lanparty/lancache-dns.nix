{ pkgs, lib, config, ... }:
with import <stockholm/lib>;
let
  # see https://github.com/zeropingheroes/lancache for full docs
  lancache-dns = pkgs.stdenv.mkDerivation rec {
    name = "lancache-dns-2017-06-28";
    src = pkgs.fetchFromGitHub {
      # forked: https://github.com/zeropingheroes/lancache-dns
      repo = "lancache-dns";
      owner = "zeropingheroes";
      rev = "420aa62";
      sha256 = "0ik7by7ripdv2avyy5kk9jp1i7rz9ksc8xmg7n9iik365q9pv94m";
    };
    phases = [ "unpackPhase" "installPhase" ];
    # here we can chance to edit `includes/proxy-cache-paths.conf`
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  stateDir = "/var/lib/unbound";
  user = "unbound";
  upstream-server = "8.8.8.8";
in {
  services.unbound = {
    enable = true;
    allowedAccess = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
    interfaces = ["0.0.0.0" "::" ];
    forwardAddresses = [ upstream-server ];
    extraConfig = ''
      include: "${stateDir}/lancache/*.conf"
    '';
  };
  services.dnscrypt-proxy.enable = lib.mkForce false;
  virtualisation.libvirtd.enable = lib.mkForce false;
  systemd.services.dns-lancache-prepare = {
      wantedBy = [ "unbound.service" ];
      before = [ "unbound.service" ];
      after = [ "network-online.target" ];
      partOf= [ "unbound.service" ];

      path = [ pkgs.gawk pkgs.iproute pkgs.gnused ];
      script = ''
        set -xeu
        current_ip=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
        old_ip=10.1.1.250
        mkdir -p ${stateDir}
        rm -rvf ${stateDir}/lancache
        cp -r ${lancache-dns}/upstreams-available ${stateDir}/lancache
        sed -i "s/$old_ip/$current_ip/g" ${stateDir}/lancache/*.conf
        chown -R unbound ${stateDir}
        '';
    };
  networking.firewall.allowedUDPPorts = [ 53 ];
}
