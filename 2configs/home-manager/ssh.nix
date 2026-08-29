{ ... }:
{
  home-manager.users.makefu = { ... }: let
    torProxy = "/run/current-system/sw/bin/nc -X 5 -x 127.0.0.1:9050 %h %p";
    jump = host: "ssh ${host} -W %h:%p";
  in {
    programs.ssh = {
      enable = true;
      # only manage the blocks defined here, do not emit home-manager's
      # opinionated defaults into ~/.ssh/config
      enableDefaultConfig = false;

      # attribute names are the Host pattern, attribute keys are ssh_config(5)
      # directive names. ssh(1) takes the *first* value found for each keyword;
      # the catch-all block is the "*" entry, which the module always emits
      # last, after every other block.
      settings = {
        # --- wbob and friends -------------------------------------------
        wbob = {
          HostName = "wbob";
          ProxyCommand = jump "gum.i";
        };
        # wbob has no route from the outside; it is only reachable from
        # cybahn.de inside the euer wireguard net.
        "wbob.euer wbob.cybahn" = {
          HostName = "172.27.61.2";
          User = "root";
          ProxyJump = "root@cybahn.de";
        };
        wbob-localhost = {
          HostName = "127.0.0.1";
          Port = 2222;
          User = "kiosk";
        };
        wbob-chatgts = {
          HostName = "192.168.8.243";
          User = "chatgts";
          ProxyCommand = jump "wbob";
        };
        wbob-proxy = {
          HostName = "192.168.8.1";
          ProxyCommand = jump "wbob";
        };
        wbobbuild = {
          User = "nixBuild";
          HostName = "wbob.r";
          IdentityFile = "/home/makefu/secrets/x/id_nixBuild";
        };
        vbob-remote = {
          HostName = "192.168.8.225";
          ProxyCommand = jump "wbob-proxy";
        };

        # --- own machines -----------------------------------------------
        gum.User = "makefu";
        nextgum = {
          HostName = "nextgum.i";
          User = "makefu";
        };
        omo = {
          HostName = "omo";
          User = "makefu";
          IdentityFile = "/home/makefu/.ssh/id_rsa";
          ProxyCommand = jump "gum";
          StrictHostKeyChecking = "no";
        };
        filepimp.User = "root";
        darth.User = "makefu";
        euer.User = "makefu";
        cband.User = "makefu";
        chinaman.User = "root";
        vault.User = "root";
        kremium.User = "root";
        pigstarter.User = "makefu";
        "pigstarter.krebsco.de".User = "makefu";
        savarcast = {
          HostName = "home.savar.de";
          Port = 2299;
          User = "root";
        };
        savarcast-test = {
          HostName = "192.168.56.10";
          User = "root";
        };
        vbox = {
          HostName = "127.0.0.1";
          Port = 2222;
          User = "root";
        };
        servarch = {
          HostName = "192.168.1.11";
          User = "makefu";
          Compression = false;
          ControlMaster = "no";
        };
        leechi = {
          HostName = "leechi.kicks-ass.org";
          User = "makefu";
          Port = 443;
        };
        warchall = {
          HostName = "warchall.net";
          User = "makefu";
          Port = 19198;
        };
        asterisk = {
          HostName = "213.239.205.246";
          Port = 10022;
          User = "root";
        };
        "cgit.euer.krebsco.de" = {
          HostName = "cgit.euer.krebsco.de";
          User = "forgejo";
          IdentityFile = "~/.ssh/keys/forgejo";
        };
        "aarch64.nixos.community" = {
          HostName = "aarch64.nixos.community";
          User = "makefu";
          IdentityFile = "/home/makefu/.ssh/keys/nix-community";
        };

        # --- shackspace --------------------------------------------------
        "alphapi.shack".IdentityFile = "~/.ssh/gitlab-ci-deploy";
        "ssh.git.shackspace.de".ProxyCommand = jump "gum";
        inter_ibu = {
          # contains wolf
          HostName = "ibuprofen.shack";
          Compression = false;
          ProxyCommand = jump "puyak";
        };
        "openhab.shack" = {
          HostName = "openhab.shack";
          ProxyCommand = jump "wolf";
        };
        phenyl = {
          # contains nukular
          HostName = "10.42.2.3";
          Compression = false;
          ProxyCommand = jump "wolf";
        };
        inter_rzgit = {
          HostName = "rzgit.shack";
          ProxyCommand = jump "wolf";
        };
        inter_openwisp = {
          HostName = "openwisp.shack";
          User = "shack";
          ProxyJump = "wolf";
        };
        inter_wolf = {
          HostName = "10.42.14.120";
          User = "root";
          ProxyCommand = jump "wolf";
        };
        inter_migraine = {
          HostName = "migraine.shack";
          User = "root";
        };
        inter_asperine = {
          HostName = "asperine.shack";
          User = "root";
          ProxyCommand = jump "heidi";
        };
        heidi = {
          HostName = "heidi.shack";
          User = "root";
          ProxyCommand = jump "wolf";
        };
        "filebitch.shack" = {
          HostName = "10.42.14.43";
          User = "root";
          Compression = false;
          ProxyCommand = jump "wolf";
        };
        "monitoring.shack".User = "root";
        "krebs.shack".User = "krebs";
        ibu_v6 = {
          HostName = "2001:4dd0:ae02:fefe:da9d:67ff:fe25:a520";
          User = "root";
        };
        "coreswitch.shack" = {
          HostName = "10.0.0.3";
          Port = 22;
          User = "napalm";
          IdentityFile = "/dev/null";
          IdentitiesOnly = true;
          ForwardAgent = false;
          KexAlgorithms = "+curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group1-sha1";
          Ciphers = "+aes192-cbc";
        };
        portal = {
          HostName = "192.168.1.1";
          User = "open";
          IdentityFile = "/home/makefu/.ssh/shackspace";
        };

        # --- siem lab ----------------------------------------------------
        "ossim.siem" = {
          HostName = "10.8.10.6";
          User = "root";
        };
        honeydrive = {
          HostName = "10.8.8.8";
          Port = 22222;
          User = "root";
          ProxyCommand = jump "ossim.siem";
        };

        # --- misc third party --------------------------------------------
        "manga.madokami.al" = {
          Port = 38460;
          User = "homura";
          KexAlgorithms = "diffie-hellman-group-exchange-sha1";
        };
        prism.User = "download";
        krebs.User = "krebs";
        fuerkrebs.User = "krebs";
        krebsplug.User = "root";
        shepherd.User = "user";
        alphalabs.User = "guest";
        raspafari.User = "pi";
        soundflower.User = "pi";
        bitchctl.User = "ciko";
        pa-sharepoint.User = "default";
        chris = {
          HostName = "176.9.48.239";
          User = "felix";
        };
        archive.HostName = "192.249.58.106";
        autosync = {
          HostName = "pnp";
          User = "git";
        };
        pandora = {
          HostName = "192.168.1.1";
          User = "root";
        };
        tempsdev = {
          HostName = "127.0.0.2";
          Port = 2222;
        };
        pki = {
          HostName = "localhost";
          Port = 2222;
        };
        "10.42.23.68" = {
          HostName = "10.42.23.68";
          IdentityFile = "~/.ssh/sdev";
          ProxyCommand = jump "fileleech";
        };
        "192.168.8.1" = {
          HostName = "192.168.8.1";
          Compression = true;
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          HostKeyAlgorithms = "+ssh-rsa";
        };
        "192.168.111.5" = {
          Compression = true;
          HostKeyAlgorithms = "+ssh-rsa";
        };
        "direct.labs.play-with-docker.com".ControlPath = "~/.ssh/%r@docker";
        "*.labs.overthewire.org".SendEnv = [
          "WECHALLTOKEN"
          "WECHALLUSER"
        ];

        # --- reached through tor -----------------------------------------
        edu = {
          HostName = "23.92.64.72";
          User = "root";
          ProxyCommand = torProxy;
        };
        candy = {
          HostName = "162.248.11.162";
          User = "root";
          ProxyCommand = torProxy;
        };
        "*.onion".ProxyCommand = torProxy;

        # --- catch-all, emitted last by the module ------------------------
        "*" = {
          User = "root";
          Compression = true;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/ssh-%C.sock";
        };
      };
    };
  };
}
