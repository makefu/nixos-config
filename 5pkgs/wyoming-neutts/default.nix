# Wyoming-protocol TTS server for NeuTTS German, packaged as a single wrapped
# entrypoint `wyoming-neutts`. Reuses the neutts python module (from the 5pkgs
# overlay) plus everything else from nixpkgs. A German reference clip + its
# transcript are baked in as the default voice for NeuTTS' voice cloning.
{ lib
, python3
, fetchurl
, makeWrapper
, runCommand
}:
let
  # ignoreCollisions: einx and phonemizer both (wrongly) install a
  # docs/source/conf.py into site-packages, whose .pyc collides in buildEnv.
  # The clash is only stale documentation artifacts, harmless to the runtime.
  pythonEnv = python3.buildEnv.override {
    extraLibs = with python3.pkgs; [
      neutts
      wyoming
      llama-cpp-python
      soundfile
      numpy
      huggingface-hub
    ];
    ignoreCollisions = true;
  };

  # German reference voice from the NeuTTS repo samples.
  refWav = fetchurl {
    url = "https://raw.githubusercontent.com/neuphonic/neutts/main/samples/greta.wav";
    hash = "sha256-r5Fn/HboJMyORs4a/svDFExryEGVup/ZiE3pVxbdVTQ=";
  };
  refTxt = fetchurl {
    url = "https://raw.githubusercontent.com/neuphonic/neutts/main/samples/greta.txt";
    hash = "sha256-qyrLTtbHi5xPzOEh8iKozNq5DI0iijsG9Tmle6pbt5Y=";
  };
in
runCommand "wyoming-neutts-1.2.1"
{
  nativeBuildInputs = [ makeWrapper ];
  meta = with lib; {
    description = "Wyoming protocol TTS server for NeuTTS Nano German";
    homepage = "https://github.com/neuphonic/neutts";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "wyoming-neutts";
  };
} ''
  install -Dm644 ${./server.py} $out/share/wyoming-neutts/server.py
  install -Dm644 ${refWav} $out/share/wyoming-neutts/voice.wav
  install -Dm644 ${refTxt} $out/share/wyoming-neutts/voice.txt
  makeWrapper ${pythonEnv}/bin/python3 $out/bin/wyoming-neutts \
    --add-flags "$out/share/wyoming-neutts/server.py" \
    --add-flags "--voice-wav $out/share/wyoming-neutts/voice.wav" \
    --add-flags "--voice-text-file $out/share/wyoming-neutts/voice.txt"
''
