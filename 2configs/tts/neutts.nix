# NeuTTS German text-to-speech, exposed over the Wyoming protocol so Home
# Assistant's built-in Wyoming integration can use it as a TTS engine.
#
# Point HA at tcp://<this-host>.euer:10201 (Settings -> Devices & Services ->
# Wyoming Protocol). The model (GGUF Q8 backbone + neucodec) is downloaded from
# HuggingFace into the service StateDirectory on first synthesize and cached
# afterwards, so the first request after a fresh deploy is slow.
#
# Voice cloning: every advertised voice is a reference clip (<name>.wav plus its
# transcript <name>.txt). Add voices two ways:
#   * declaratively via `services.neutts.voices.<name> = { audio; text; };`
#   * at runtime by dropping <name>.wav + <name>.txt into
#     /var/lib/neutts/voices and restarting the service.
{ config, pkgs, lib, ... }:
let
  cfg = config.services.neutts;

  # Build a read-only directory of the declarative reference clips.
  declVoices = pkgs.runCommand "neutts-decl-voices" { } (''
    mkdir -p $out
  '' + lib.concatStrings (lib.mapAttrsToList (name: v: ''
    install -Dm444 ${v.audio} "$out/${name}.wav"
    install -Dm444 ${pkgs.writeText "${name}.txt" v.text} "$out/${name}.txt"
  '') cfg.voices));
in
{
  options.services.neutts.backboneRepo = lib.mkOption {
    type = lib.types.str;
    default = "neuphonic/neutts-nano-german-q8-gguf";
    description = "NeuTTS backbone: a HuggingFace repo id or a local GGUF path.";
  };

  options.services.neutts.voices = lib.mkOption {
    description = ''
      Extra NeuTTS voices to clone. Each entry is a reference audio clip and the
      transcript of what is spoken in it (mono, ~3-15 s of clean speech).
    '';
    default = { };
    example = lib.literalExpression ''
      { alice = { audio = ./alice.wav; text = "Guten Tag, ich bin Alice."; }; }
    '';
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        audio = lib.mkOption {
          type = lib.types.path;
          description = "Reference .wav clip.";
        };
        text = lib.mkOption {
          type = lib.types.str;
          description = "Transcript of the reference clip.";
        };
      };
    });
  };

  config = {
    systemd.services.wyoming-neutts = {
      description = "NeuTTS German Wyoming TTS server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        HF_HOME = "/var/lib/neutts/hf-cache";
        HF_HUB_ENABLE_HF_TRANSFER = "0";
        # x230 has 4 threads; leave the box responsive during synthesis.
        OMP_NUM_THREADS = "4";
        NUMBA_CACHE_DIR = "/var/lib/neutts/numba-cache";
      };
      serviceConfig = {
        ExecStart = "${pkgs.wyoming-neutts}/bin/wyoming-neutts --uri tcp://0.0.0.0:10201"
          + " --backbone-repo ${cfg.backboneRepo}"
          + " --voices-dir ${declVoices}"          # nix-declared voices
          + " --voices-dir /var/lib/neutts/voices"; # runtime drop-in voices
        DynamicUser = true;
        StateDirectory = "neutts neutts/voices";
        WorkingDirectory = "/var/lib/neutts";
        Restart = "on-failure";
        RestartSec = "10";
        # first run downloads ~300 MB and does a slow CPU model init
        TimeoutStartSec = "900";
      };
    };

    # x2 sits on the euer wireguard overlay (root@x2.euer); expose the TTS port
    # to euer peers only, not to whatever roaming LAN NetworkManager attaches to.
    networking.firewall.interfaces.euer.allowedTCPPorts = [ 10201 ];
  };
}
