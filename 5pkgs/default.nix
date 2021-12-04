self: super:
with super.lib; with builtins; let
  # This callPackage will try to detect obsolete overrides.
  callPackage = path: args: let
    override =  super.callPackage path args;
    upstream = optionalAttrs (override ? "name")
      (super.${(parseDrvName override.name).name} or {});
  in if upstream ? "name" &&
        override ? "name" &&
        compareVersions upstream.name override.name != -1
    then
      trace
        "Upstream `${upstream.name}' gets overridden by `${override.name}'."
        override
    else override;

   eq = x: y: x == y;
   subdirsOf = path:
     mapAttrs (name: _: path + "/${name}")
              (filterAttrs (_: eq "directory") (readDir path));

in {
    quodlibet = super.pkgs.lib.overrideDerivation super.quodlibet (old: {
      doCheck = false; # 1 error because of warnings (possibly upstream)
      patches = [ ./custom/quodlibet/single-digit-discnumber.patch
                  ./custom/quodlibet/remove-override-warning.patch ];
    });
    #rclone = super.pkgs.lib.overrideDerivation super.rclone (old: {
    #  postInstall = old.postInstall + ''

    #        $out/bin/rclone genautocomplete zsh _rclone
    #        install -D -m644 _rclone $out/share/zsh/vendor-completions/_rclone
    #        $out/bin/rclone genautocomplete bash _rclone
    #        install -D -m644 _rclone $out/etc/bash_completion.d/rclone
    #    '';
    #});
    alsa-hdspconf = callPackage ./custom/alsa-tools { alsaToolTarget="hdspconf";};
    alsa-hdspmixer = callPackage ./custom/alsa-tools { alsaToolTarget="hdspmixer";};
    alsa-hdsploader = callPackage ./custom/alsa-tools { alsaToolTarget="hdsploader";};
    qcma = super.pkgs.libsForQt5.callPackage ./custom/qcma { };
    inherit (callPackage ./devpi {}) devpi-web ;
    nodemcu-uploader = super.pkgs.callPackage ./nodemcu-uploader {};
    liveproxy = super.pkgs.python3Packages.callPackage ./custom/liveproxy {};
    mediawiki-matrix-bot = super.pkgs.python3Packages.callPackage ./custom/mediawiki-matrix-bot {};
    hydra-check = super.pkgs.python3Packages.callPackage ./custom/hydra-check {};
    pwqgen-ger = super.pkgs.passwdqc-utils.override {
      wordset-file = super.pkgs.fetchurl {
        urls = [
          https://gist.githubusercontent.com/makefu/b56f5554c9ef03fe6e09878962e6fd8d/raw/1f147efec51325bc9f80c823bad8381d5b7252f6/wordset_4k.c
          https://archive.org/download/nixos-stockholm-tarballs/pviar5j1gxiqcf3l34b4n2pil06xc8zf-wordset_4k.c
        ];
        sha256 = "18ddzyh11bywrhzdkzvrl7nvgp5gdb4k1s0zxbz2bkhd14vi72bb";
      };
    };

}

// (mapAttrs (_: flip callPackage {})
            (filterAttrs (_: dir: pathExists (dir + "/default.nix"))
                         (subdirsOf ./.)))
