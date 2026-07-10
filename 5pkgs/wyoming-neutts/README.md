# wyoming-neutts

A [Wyoming protocol](https://github.com/rhasspy/wyoming) text-to-speech server
wrapping [NeuTTS Nano German](https://huggingface.co/neuphonic/neutts-nano-german).
Home Assistant's built-in *Wyoming Protocol* integration can use it directly as
a TTS engine (Settings → Devices & Services → Wyoming Protocol →
`tcp://<host>.euer:10201`).

NeuTTS does **instant voice cloning**: it does not ship fixed speaker voices.
Instead every voice is a *reference clip* — a short recording plus its exact
transcript — that the model mimics. This file explains how to produce those
reference clips.

## What a voice consists of

Each voice is a pair of files that share a base name:

```
<name>.wav    # the reference recording
<name>.txt    # the exact transcript of what is spoken in <name>.wav
```

The base name `<name>` becomes the voice name advertised to Home Assistant.

## Reference audio requirements

Follow the NeuTTS model card recommendations for good cloning quality:

- **Format:** mono WAV, 16-bit PCM.
- **Sample rate:** 16–44 kHz (the server resamples to 16 kHz internally).
- **Length:** ~3–15 seconds. Shorter clones poorly; longer wastes context.
- **Content:** clean, continuous speech — one speaker, no music, no background
  noise, minimal silence at the ends.
- **Language:** German for this model. The transcript's language must match what
  is actually spoken.
- **Style:** the clone mirrors the reference's tone, pace and emotion, so record
  in the delivery you want out.

## Creating a reference clip

### 1. Record or trim audio

Record a clean German sentence (a phone voice-memo in a quiet room works), then
normalise it to mono 16-bit and trim to a good ~3–15 s take:

```sh
# convert anything to mono 24 kHz 16-bit and trim to 10 s
ffmpeg -i raw.m4a -ac 1 -ar 24000 -sample_fmt s16 -t 10 alice.wav

# optional: trim leading/trailing silence
sox alice.wav alice_trim.wav silence 1 0.1 1% reverse silence 1 0.1 1% reverse
```

Listen back and make sure the clip is clean and the speech is continuous.

### 2. Write the transcript

Put the **exact** words spoken in the clip into `<name>.txt` — correct casing
and punctuation, no extra lines:

```sh
printf '%s' "Guten Tag, ich bin Alice und lese Ihnen die Nachrichten vor." > alice.txt
```

Accuracy matters: a transcript that does not match the audio degrades the clone.

### 3. Sanity-check (optional)

You can verify a pair locally with the NeuTTS Python API before deploying:

```python
from neutts import NeuTTS
import soundfile as sf

tts = NeuTTS(backbone_repo="neuphonic/neutts-nano-german-q8-gguf",
             codec_repo="neuphonic/neucodec")
ref = tts.encode_reference("alice.wav")
wav = tts.infer("Ein kurzer Test der geklonten Stimme.", ref,
                open("alice.txt").read().strip())
sf.write("out.wav", wav, 24000)
```

## Installing a voice

Two ways, both wired up in `2configs/tts/neutts.nix`:

### Declaratively (NixOS)

```nix
services.neutts.voices.alice = {
  audio = ./voices/alice.wav;
  text  = "Guten Tag, ich bin Alice und lese Ihnen die Nachrichten vor.";
};
```

Rebuild the host. The voice `alice` is baked into the store and advertised on
the next service start.

### At runtime (drop-in)

Copy the pair onto the host and restart the service:

```sh
scp alice.wav alice.txt root@<host>.euer:/var/lib/neutts/voices/
ssh root@<host>.euer systemctl restart wyoming-neutts
```

The server scans `/var/lib/neutts/voices` (and any `--voices-dir`) on start;
`<name>.wav` needs a sibling `<name>.txt` or it is skipped.

## Selecting a voice

The default voice (`neutts-german`) is used when a request names no voice. In
Home Assistant, choose the voice per TTS call, or set it as the pipeline default.
Over raw Wyoming, set `Synthesize.voice.name` to the voice's `<name>`.

## Server options

```
--voice-wav PATH         default reference .wav (baked in by the package)
--voice-text[-file] ...  transcript for the default reference
--voices-dir DIR         extra <name>.wav + <name>.txt clips (repeatable)
--backbone-repo REPO     HF repo id or local GGUF path
--language CODE          eSpeak language code (default: de)
--uri URI                default tcp://0.0.0.0:10201
--preload                load the model at startup instead of first request
```
