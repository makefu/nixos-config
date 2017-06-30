{ pkgs, lib, config, ... }:
with import <stockholm/lib>;
let
  # see https://github.com/zeropingheroes/lancache for full docs
  lancache= pkgs.stdenv.mkDerivation rec {
    name = "lancache-2017-06-26";
    src = pkgs.fetchFromGitHub {
      # origin: https://github.com/multiplay/lancache
      # forked: https://github.com/zeropingheroes/lancache
      repo = "lancache";
      owner = "zeropingheroes";
      rev = "143f7bb";
      sha256 = "1ra4l7qz3k231j5wabr89s5hh80n1kk8vgd3dsh0xx5mdpjhvdl6";
    };
    phases = [ "unpackPhase" "installPhase" ];
    # here we can chance to edit `includes/proxy-cache-paths.conf`
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
      sed -i -e 's/^\(user\).*/\1 ${cfg.user} ${cfg.group};/' \
             -e '1 idaemon off;' \
              $out/nginx.conf
    '';
  };
  cfg = {
    group = "nginx-lancache";
    user = "nginx-lancache";
    statedir = "/var/lancache";
    package = pkgs.stdenv.lib.overrideDerivation pkgs.nginx (old:{
      configureFlags = old.configureFlags ++ [
        "--with-http_slice_module"
        "--with-stream"
        "--with-pcre"
        ];
    });
  };
in {
  systemd.services.nginx-lancache = {
    description = "Nginx lancache Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = true;

    preStart = ''
      mkdir -p ${cfg.statedir} && cd ${cfg.statedir}
      PATH_CACHE=$PATH_BASE/cache
      PATH_LOGS=$PATH_BASE/logs

      mkdir -p cache/{installers,tmp} logs
      rm -f conf; ln -s ${lancache} conf
      chown -R ${cfg.user}:${cfg.group} .
      '';
    serviceConfig = {
      ExecStart = "${cfg.package}/bin/nginx  -p ${cfg.statedir}";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "always";
      RestartSec = "10s";
      StartLimitInterval = "1min";
    };
  };

  environment.etc.nginx.source = lancache;
    users.extraUsers = (singleton
  { name = cfg.user;
    group = cfg.group;
    uid = genid cfg.group;
  });

  users.extraGroups = (singleton
    { name = "${cfg.group}";
      gid = genid cfg.group;
  });
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
