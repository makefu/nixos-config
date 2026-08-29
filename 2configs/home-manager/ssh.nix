{ ... }:
{
  home-manager.users.makefu = { lib, ... }: let
    dag = lib.hm.dag;

    # ssh(1) takes the *first* value found for each keyword, so a catch-all
    # block has to be emitted last or its "User root" would win everywhere.
    torProxy = "/run/current-system/sw/bin/nc -X 5 -x 127.0.0.1:9050 %h %p";
    jump = host: "ssh ${host} -W %h:%p";
  in {
    programs.ssh = {
      enable = true;
      # only manage the blocks defined here, do not emit home-manager's
      # opinionated defaults into ~/.ssh/config
      enableDefaultConfig = false;

      matchBlocks = {
        # --- wbob and friends -------------------------------------------
        wbob = {
          hostname = "wbob";
          proxyCommand = jump "gum.i";
        };
        # wbob has no route from the outside; it is only reachable from
        # cybahn.de inside the euer wireguard net.
        "wbob.euer" = {
          host = "wbob.euer wbob.cybahn";
          hostname = "172.27.61.2";
          user = "root";
          proxyJump = "root@cybahn.de";
        };
        wbob-localhost = {
          hostname = "127.0.0.1";
          port = 2222;
          user = "kiosk";
        };
        wbob-chatgts = {
          hostname = "192.168.8.243";
          user = "chatgts";
          proxyCommand = jump "wbob";
        };
        wbob-proxy = {
          hostname = "192.168.8.1";
          proxyCommand = jump "wbob";
        };
        wbobbuild = {
          user = "nixBuild";
          hostname = "wbob.r";
          identityFile = "/home/makefu/secrets/x/id_nixBuild";
        };
        vbob-remote = {
          hostname = "192.168.8.225";
          proxyCommand = jump "wbob-proxy";
        };

        # --- own machines -----------------------------------------------
        gum.user = "makefu";
        nextgum = {
          hostname = "nextgum.i";
          user = "makefu";
        };
        omo = {
          hostname = "omo";
          user = "makefu";
          identityFile = "/home/makefu/.ssh/id_rsa";
          proxyCommand = jump "gum";
          extraOptions.StrictHostKeyChecking = "no";
        };
        filepimp.user = "root";
        darth.user = "makefu";
        euer.user = "makefu";
        cband.user = "makefu";
        chinaman.user = "root";
        vault.user = "root";
        kremium.user = "root";
        pigstarter.user = "makefu";
        "pigstarter.krebsco.de".user = "makefu";
        savarcast = {
          hostname = "home.savar.de";
          port = 2299;
          user = "root";
        };
        savarcast-test = {
          hostname = "192.168.56.10";
          user = "root";
        };
        vbox = {
          hostname = "127.0.0.1";
          port = 2222;
          user = "root";
        };
        servarch = {
          hostname = "192.168.1.11";
          user = "makefu";
          compression = false;
          controlMaster = "no";
          forwardX11 = false;
        };
        leechi = {
          hostname = "leechi.kicks-ass.org";
          user = "makefu";
          port = 443;
        };
        warchall = {
          hostname = "warchall.net";
          user = "makefu";
          port = 19198;
        };
        asterisk = {
          hostname = "213.239.205.246";
          port = 10022;
          user = "root";
        };
        "cgit.euer.krebsco.de" = {
          hostname = "cgit.euer.krebsco.de";
          user = "forgejo";
          identityFile = "~/.ssh/keys/forgejo";
        };
        "aarch64.nixos.community" = {
          hostname = "aarch64.nixos.community";
          user = "makefu";
          identityFile = "/home/makefu/.ssh/keys/nix-community";
        };

        # --- shackspace --------------------------------------------------
        "alphapi.shack".identityFile = "~/.ssh/gitlab-ci-deploy";
        "ssh.git.shackspace.de".proxyCommand = jump "gum";
        inter_ibu = {
          # contains wolf
          hostname = "ibuprofen.shack";
          compression = false;
          proxyCommand = jump "puyak";
        };
        "openhab.shack" = {
          hostname = "openhab.shack";
          proxyCommand = jump "wolf";
        };
        phenyl = {
          # contains nukular
          hostname = "10.42.2.3";
          compression = false;
          proxyCommand = jump "wolf";
        };
        inter_rzgit = {
          hostname = "rzgit.shack";
          proxyCommand = jump "wolf";
        };
        inter_openwisp = {
          hostname = "openwisp.shack";
          user = "shack";
          proxyJump = "wolf";
        };
        inter_wolf = {
          hostname = "10.42.14.120";
          user = "root";
          proxyCommand = jump "wolf";
        };
        inter_migraine = {
          hostname = "migraine.shack";
          user = "root";
        };
        inter_asperine = {
          hostname = "asperine.shack";
          user = "root";
          proxyCommand = jump "heidi";
        };
        heidi = {
          hostname = "heidi.shack";
          user = "root";
          proxyCommand = jump "wolf";
        };
        "filebitch.shack" = {
          hostname = "10.42.14.43";
          user = "root";
          compression = false;
          proxyCommand = jump "wolf";
        };
        "monitoring.shack".user = "root";
        "krebs.shack".user = "krebs";
        ibu_v6 = {
          hostname = "2001:4dd0:ae02:fefe:da9d:67ff:fe25:a520";
          user = "root";
        };
        "coreswitch.shack" = {
          hostname = "10.0.0.3";
          port = 22;
          user = "napalm";
          identityFile = "/dev/null";
          identitiesOnly = true;
          forwardAgent = false;
          extraOptions = {
            KexAlgorithms = "+curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group1-sha1";
            Ciphers = "+aes192-cbc";
          };
        };
        portal = {
          hostname = "192.168.1.1";
          user = "open";
          identityFile = "/home/makefu/.ssh/shackspace";
        };

        # --- siem lab ----------------------------------------------------
        "ossim.siem" = {
          hostname = "10.8.10.6";
          user = "root";
        };
        honeydrive = {
          hostname = "10.8.8.8";
          port = 22222;
          user = "root";
          proxyCommand = jump "ossim.siem";
        };

        # --- misc third party --------------------------------------------
        "manga.madokami.al" = {
          port = 38460;
          user = "homura";
          extraOptions.KexAlgorithms = "diffie-hellman-group-exchange-sha1";
        };
        prism.user = "download";
        krebs.user = "krebs";
        fuerkrebs.user = "krebs";
        krebsplug.user = "root";
        shepherd.user = "user";
        alphalabs.user = "guest";
        raspafari.user = "pi";
        soundflower.user = "pi";
        bitchctl.user = "ciko";
        pa-sharepoint.user = "default";
        chris = {
          hostname = "176.9.48.239";
          user = "felix";
        };
        archive.hostname = "192.249.58.106";
        autosync = {
          hostname = "pnp";
          user = "git";
        };
        pandora = {
          hostname = "192.168.1.1";
          user = "root";
        };
        tempsdev = {
          hostname = "127.0.0.2";
          port = 2222;
        };
        pki = {
          hostname = "localhost";
          port = 2222;
        };
        "10.42.23.68" = {
          hostname = "10.42.23.68";
          identityFile = "~/.ssh/sdev";
          proxyCommand = jump "fileleech";
        };
        "192.168.8.1" = {
          hostname = "192.168.8.1";
          compression = true;
          extraOptions = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
            HostKeyAlgorithms = "+ssh-rsa";
          };
        };
        "192.168.111.5" = {
          compression = true;
          extraOptions.HostKeyAlgorithms = "+ssh-rsa";
        };
        "direct.labs.play-with-docker.com".controlPath = "~/.ssh/%r@docker";
        "*.labs.overthewire.org".sendEnv = [
          "WECHALLTOKEN"
          "WECHALLUSER"
        ];

        # --- reached through tor -----------------------------------------
        edu = {
          hostname = "23.92.64.72";
          user = "root";
          proxyCommand = torProxy;
        };
        candy = {
          hostname = "162.248.11.162";
          user = "root";
          proxyCommand = torProxy;
        };
        "*.onion".proxyCommand = torProxy;

        # --- catch-all, must stay last -----------------------------------
        "*" = dag.entryAfter [ "*.onion" "*.labs.overthewire.org" ] {
          user = "root";
          compression = true;
          controlMaster = "auto";
          controlPath = "~/.ssh/ssh-%C.sock";
        };
      };
    };
  };
}
