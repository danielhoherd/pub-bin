#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "<3.13"
# dependencies = [
#   "openai-whisper",
# ]
# ///
# Author: github.com/danielhoherd (with GH copilot GPT-4.1)
# License: MIT
"""Transcribe media files using OpenAI's Whisper model, with timestamps.

This script transcribes audio and video files using the Whisper model from
OpenAI, and creates a .txt or .srt file next to the source media file.

See https://github.com/openai/whisper for more information."""

import argparse
import sys
from pathlib import Path

import whisper


def format_timestamp(seconds: float) -> str:
    """Format seconds to SRT timestamp (hh:mm:ss,ms)"""
    minutes, secs = divmod(int(seconds), 60)
    hours, minutes = divmod(minutes, 60)
    ms = int((seconds - int(seconds)) * 1000)
    return f"{hours:02}:{minutes:02}:{secs:02},{ms:03}"


def transcribe_file(model, file_path, srt: bool = False):
    result = model.transcribe(str(file_path), verbose=False)
    if srt and "segments" in result:
        # SRT format
        lines = []
        for i, seg in enumerate(result["segments"], 1):
            start = format_timestamp(seg["start"])
            end = format_timestamp(seg["end"])
            text = seg["text"].strip()
            lines.append(f"{i}\n{start} --> {end}\n{text}\n")
        return "\n".join(lines)
    if "segments" in result:
        # Human-readable with timestamps
        paragraphs = []
        for seg in result["segments"]:
            start = format_timestamp(seg["start"])
            text = seg["text"].strip()
            paragraphs.append(f"[{start}] {text}")
        return "\n\n".join(paragraphs)
    # Fallback: plain text
    return result["text"] if isinstance(result, dict) and "text" in result else str(result)


def get_output_path(input_path, srt: bool = False):
    return input_path.with_suffix(".srt" if srt else ".txt")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument(
        "files",
        metavar="FILE",
        nargs="+",
        type=Path,
        help="media file(s) to transcribe",
    )
    parser.add_argument(
        "--model",
        default="base",
        help="Whisper model to use (default: base)",
    )
    parser.add_argument(
        "--srt",
        action="store_true",
        help="Output subtitles in SRT format instead of plain text",
    )

    args = parser.parse_args()

    try:
        model = whisper.load_model(args.model)
    except RuntimeError as e:
        print(f"Error loading model '{args.model}': {e}", file=sys.stderr)
        sys.exit(1)

    for file in args.files:
        print(f"Transcribing: {file}")
        try:
            text = transcribe_file(model, file, srt=args.srt)
            output_path = get_output_path(file, srt=args.srt)
            output_path.write_text(text, encoding="utf-8")
            print(f"Transcription written to: {output_path}")
        except Exception as e:  # noqa: BLE001
            print(f"Failed to transcribe {file}: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
