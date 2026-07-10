#!/usr/bin/env python3
"""Minimal Wyoming client used by the NeuTTS VM test.

Connects to the server, asks it to describe itself (must advertise a German TTS
voice), sends a synthesize request (optionally selecting a cloned voice) and
asserts a non-trivial amount of PCM audio comes back framed by
audio-start / audio-stop. Exits non-zero on any failure.
"""
import argparse
import asyncio
import wave

from wyoming.audio import AudioChunk, AudioStart, AudioStop
from wyoming.client import AsyncClient
from wyoming.info import Describe, Info
from wyoming.tts import Synthesize, SynthesizeVoice


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("uri")
    parser.add_argument("text", nargs="?", default="Hallo Welt, dies ist ein Test.")
    parser.add_argument("--voice", help="select a cloned voice by name")
    parser.add_argument("--out", help="write received audio to this .wav")
    args = parser.parse_args()

    async with AsyncClient.from_uri(args.uri) as client:
        # Describe -> Info
        await client.write_event(Describe().event())
        info = None
        while True:
            event = await client.read_event()
            if event is None:
                raise SystemExit("connection closed before Info")
            if Info.is_type(event.type):
                info = Info.from_event(event)
                break
        assert info.tts, "server advertised no tts programs"
        voices = info.tts[0].voices
        assert voices, "tts program advertised no voices"
        assert any("de" in v.languages for v in voices), "no German voice"
        names = [v.name for v in voices]
        print(f"info OK: voices={names}", flush=True)
        if args.voice:
            assert args.voice in names, f"requested voice {args.voice!r} not advertised"

        # Synthesize -> audio
        synthesize = Synthesize(text=args.text)
        if args.voice:
            synthesize.voice = SynthesizeVoice(name=args.voice)
        await client.write_event(synthesize.event())

        started = stopped = False
        total = 0
        rate = width = channels = None
        pcm = bytearray()
        while True:
            event = await client.read_event()
            if event is None:
                break
            if AudioStart.is_type(event.type):
                started = True
                start = AudioStart.from_event(event)
                rate, width, channels = start.rate, start.width, start.channels
            elif AudioChunk.is_type(event.type):
                audio = AudioChunk.from_event(event).audio
                total += len(audio)
                pcm.extend(audio)
            elif AudioStop.is_type(event.type):
                stopped = True
                break

        assert started, "no AudioStart received"
        assert stopped, "no AudioStop received"
        # >0.5 s of 24 kHz 16-bit mono audio
        assert total > 24000, f"too little audio returned: {total} bytes"
        print(f"synth OK: voice={args.voice or 'default'} audio_bytes={total}", flush=True)

        if args.out:
            with wave.open(args.out, "wb") as wav:
                wav.setnchannels(channels or 1)
                wav.setsampwidth(width or 2)
                wav.setframerate(rate or 24000)
                wav.writeframes(pcm)
            print(f"wrote {args.out}", flush=True)


asyncio.run(main())
