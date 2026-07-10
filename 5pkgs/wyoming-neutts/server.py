#!/usr/bin/env python3
"""Wyoming protocol TTS server wrapping NeuTTS (German nano, GGUF Q8).

Speaks the Wyoming protocol so Home Assistant's built-in Wyoming integration can
use it as a text-to-speech engine. NeuTTS clones a voice from a reference clip
(a short .wav plus its transcript), so every advertised Wyoming voice is one
such reference pair:

  * a baked-in default German reference (--voice-wav / --voice-text), and
  * any number of extra references discovered in --voices-dir directories,
    where each ``<name>.wav`` with a sibling ``<name>.txt`` becomes voice
    ``<name>`` (see https://huggingface.co/neuphonic/neutts-nano-german).

Home Assistant picks a voice by name; the request's voice selects which
reference clip clones the output. Reference clips should be mono, ~3-15 s of
clean continuous speech; the transcript must match what is spoken.

The model is loaded once on first synthesize (download + init is slow on CPU)
and reused; each voice's reference is encoded on first use and cached.
Inference is CPU-bound and blocking so it runs in a thread executor to keep the
event loop responsive.
"""
import argparse
import asyncio
import logging
from functools import partial
from pathlib import Path

import numpy as np

from wyoming.audio import AudioChunk, AudioStart, AudioStop
from wyoming.event import Event
from wyoming.info import (
    Attribution,
    Describe,
    Info,
    TtsProgram,
    TtsVoice,
)
from wyoming.server import AsyncEventHandler, AsyncServer
from wyoming.tts import Synthesize

_LOGGER = logging.getLogger("wyoming_neutts")

SAMPLE_RATE = 24_000
SAMPLE_WIDTH = 2  # int16
CHANNELS = 1
DEFAULT_VOICE_NAME = "neutts-german"

# Lazily-initialised process-global model + per-voice reference codes, guarded
# so only the first request pays the load cost and requests serialise on it.
_MODEL = None
_REF_CACHE: dict = {}  # voice name -> encoded reference codes
_MODEL_LOCK = asyncio.Lock()


def _load_model(args):
    """Blocking model load. Runs in an executor."""
    from neutts import NeuTTS

    _LOGGER.info("Loading NeuTTS backbone=%s codec=%s", args.backbone_repo, args.codec_repo)
    tts = NeuTTS(
        backbone_repo=args.backbone_repo,
        backbone_device="cpu",
        codec_repo=args.codec_repo,
        codec_device="cpu",
        # Needed when backbone is a local GGUF path (not a known repo id), since
        # NeuTTS can only auto-map language from the HuggingFace repo name.
        language=args.language,
    )
    _LOGGER.info("NeuTTS model ready")
    return tts


def _encode_reference(wav_path):
    """Blocking reference encode. Runs in an executor."""
    _LOGGER.info("Encoding reference audio %s", wav_path)
    return _MODEL.encode_reference(wav_path)


def _synthesize(text, ref_codes, ref_text):
    """Blocking synthesis. Runs in an executor. Returns int16 PCM bytes."""
    wav = _MODEL.infer(text, ref_codes, ref_text)  # float32 [-1, 1] @ 24 kHz
    wav = np.clip(np.asarray(wav, dtype=np.float32), -1.0, 1.0)
    return (wav * 32767.0).astype("<i2").tobytes()


def discover_voices(args):
    """Build the voice registry: {name: {"wav": Path, "text": str}}.

    Starts with the baked-in default voice, then adds/overrides from each
    --voices-dir. Later directories win, so a runtime dir can override a
    packaged voice of the same name.
    """
    voices: dict = {}

    default_text = args.voice_text
    if args.voice_text_file:
        default_text = Path(args.voice_text_file).read_text(encoding="utf-8").strip()
    voices[DEFAULT_VOICE_NAME] = {"wav": Path(args.voice_wav), "text": default_text}

    for d in args.voices_dir:
        directory = Path(d)
        if not directory.is_dir():
            _LOGGER.warning("voices-dir %s does not exist, skipping", directory)
            continue
        for wav in sorted(directory.glob("*.wav")):
            txt = wav.with_suffix(".txt")
            if not txt.is_file():
                _LOGGER.warning("skipping %s: no sibling %s", wav.name, txt.name)
                continue
            voices[wav.stem] = {"wav": wav, "text": txt.read_text(encoding="utf-8").strip()}

    _LOGGER.info("voices: %s", ", ".join(sorted(voices)))
    return voices


class NeuttsEventHandler(AsyncEventHandler):
    def __init__(self, wyoming_info: Info, args, *handler_args, **handler_kwargs):
        super().__init__(*handler_args, **handler_kwargs)
        self.wyoming_info_event = wyoming_info.event()
        self.args = args

    async def handle_event(self, event: Event) -> bool:
        if Describe.is_type(event.type):
            await self.write_event(self.wyoming_info_event)
            return True

        if not Synthesize.is_type(event.type):
            return True

        synthesize = Synthesize.from_event(event)
        text = " ".join(synthesize.text.strip().splitlines())

        voice_name = DEFAULT_VOICE_NAME
        if synthesize.voice and synthesize.voice.name:
            requested = synthesize.voice.name
            if requested in self.args.voices:
                voice_name = requested
            else:
                _LOGGER.warning("unknown voice %r, using %s", requested, voice_name)
        voice = self.args.voices[voice_name]
        _LOGGER.debug("Synthesize voice=%s text=%r", voice_name, text)

        loop = asyncio.get_running_loop()
        global _MODEL
        async with _MODEL_LOCK:
            if _MODEL is None:
                _MODEL = await loop.run_in_executor(None, partial(_load_model, self.args))
            if voice_name not in _REF_CACHE:
                _REF_CACHE[voice_name] = await loop.run_in_executor(
                    None, partial(_encode_reference, str(voice["wav"]))
                )
            pcm = await loop.run_in_executor(
                None, partial(_synthesize, text, _REF_CACHE[voice_name], voice["text"])
            )

        await self.write_event(
            AudioStart(rate=SAMPLE_RATE, width=SAMPLE_WIDTH, channels=CHANNELS).event()
        )
        bytes_per_chunk = SAMPLE_WIDTH * CHANNELS * self.args.samples_per_chunk
        for offset in range(0, len(pcm), bytes_per_chunk):
            await self.write_event(
                AudioChunk(
                    rate=SAMPLE_RATE,
                    width=SAMPLE_WIDTH,
                    channels=CHANNELS,
                    audio=pcm[offset : offset + bytes_per_chunk],
                ).event()
            )
        await self.write_event(AudioStop().event())
        _LOGGER.debug("Sent %d PCM bytes", len(pcm))
        return True


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--uri", default="tcp://0.0.0.0:10201")
    parser.add_argument("--backbone-repo", default="neuphonic/neutts-nano-german-q8-gguf")
    parser.add_argument("--codec-repo", default="neuphonic/neucodec")
    parser.add_argument("--language", default="de", help="eSpeak language code")
    parser.add_argument("--voice-wav", required=True, help="default reference .wav")
    grp = parser.add_mutually_exclusive_group(required=True)
    grp.add_argument("--voice-text", help="transcript of --voice-wav")
    grp.add_argument("--voice-text-file", help="file holding the transcript")
    parser.add_argument(
        "--voices-dir",
        action="append",
        default=[],
        help="directory of <name>.wav + <name>.txt reference clips (repeatable)",
    )
    parser.add_argument("--samples-per-chunk", type=int, default=1024)
    parser.add_argument("--preload", action="store_true", help="load model at startup")
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    args.voices = discover_voices(args)

    wyoming_info = Info(
        tts=[
            TtsProgram(
                name="neutts",
                description="NeuTTS Nano German (on-device, voice-cloned)",
                attribution=Attribution(
                    name="neuphonic", url="https://github.com/neuphonic/neutts"
                ),
                installed=True,
                version="1.2.1",
                voices=[
                    TtsVoice(
                        name=name,
                        description=f"NeuTTS voice {name}",
                        attribution=Attribution(
                            name="neuphonic", url="https://huggingface.co/neuphonic"
                        ),
                        installed=True,
                        version=None,
                        languages=[args.language],
                    )
                    for name in sorted(args.voices)
                ],
                supports_synthesize_streaming=False,
            )
        ],
    )

    if args.preload:
        global _MODEL
        loop = asyncio.get_running_loop()
        _MODEL = await loop.run_in_executor(None, partial(_load_model, args))

    server = AsyncServer.from_uri(args.uri)
    _LOGGER.info("Listening on %s", args.uri)
    await server.run(partial(NeuttsEventHandler, wyoming_info, args))


def run() -> None:
    asyncio.run(main())


if __name__ == "__main__":
    run()
