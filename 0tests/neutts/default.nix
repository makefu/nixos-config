# NixOS VM test: boot the wyoming-neutts service and run a real Wyoming TTS
# request against it, asserting audio comes back. Runs fully offline — the
# neucodec+w2v-bert cache and the GGUF backbone are baked into the store.
#
# Heavy: pulls ~3.5 GB of models and does CPU synthesis inside the VM, so give
# it plenty of RAM/disk/time. Build with:
#   nix build .#checks.x86_64-linux.neutts-tts
{ pkgs, self }:
let
  # apply our overlay so nodes get pkgs.wyoming-neutts + the neutts modules
  pkgs' = pkgs.extend self.overlays.default;
  modelCache = pkgs'.callPackage ./model-cache.nix { };

  # GGUF backbone as a plain file, passed to the server by path.
  gguf = pkgs.fetchurl {
    url = "https://huggingface.co/neuphonic/neutts-nano-german-q8-gguf/resolve/main/neutts-nano-german-Q8_0.gguf";
    hash = "sha256-swTc+pB4xPsOL5i/XT3xgW0+PfrBwcxESnAoqdwpgeY=";
  };

  # a reference clip to exercise declarative voice cloning
  refWav = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/neuphonic/neutts/main/samples/greta.wav";
    hash = "sha256-r5Fn/HboJMyORs4a/svDFExryEGVup/ZiE3pVxbdVTQ=";
  };

  clientEnv = pkgs'.python3.withPackages (ps: [ ps.wyoming ]);
in
pkgs'.testers.runNixOSTest {
  name = "neutts-tts";

  nodes.machine = { config, pkgs, lib, ... }: {
    imports = [ ../../2configs/tts/neutts.nix ];

    virtualisation.memorySize = 8192;
    virtualisation.cores = 4;
    virtualisation.diskSize = 6144;

    # load backbone from the local GGUF instead of the HF repo id
    services.neutts.backboneRepo = "${gguf}";
    # a declaratively cloned voice, exercised by the test
    services.neutts.voices.custom = {
      audio = refWav;
      text = "Es wurde eine Untersuchung zur Aufklärung des Unfalls eingeleitet.";
    };

    systemd.services.wyoming-neutts = {
      environment = {
        HF_HOME = lib.mkForce "${modelCache}";
        HF_HUB_OFFLINE = "1";
        TRANSFORMERS_OFFLINE = "1";
      };
      serviceConfig.TimeoutStartSec = lib.mkForce "3600";
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("wyoming-neutts.service")
    machine.wait_for_open_port(10201)
    # first synth triggers model load; allow generous time on emulated CPU
    machine.succeed(
        "${clientEnv}/bin/python3 ${./client.py} "
        "tcp://127.0.0.1:10201 'Hallo Welt, dies ist ein Test.' >&2",
        timeout=1800,
    )
    # the declaratively cloned voice must synthesize too
    machine.succeed(
        "${clientEnv}/bin/python3 ${./client.py} "
        "tcp://127.0.0.1:10201 'Hallo aus der geklonten Stimme.' --voice custom >&2",
        timeout=600,
    )
  '';
}
