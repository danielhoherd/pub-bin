#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "<3.13"
# dependencies = [
#   "openai-whisper",
# ]
# ///
# Author: github.com/danielhoherd (with GH copilot GPT-4.1)
# License: MIT
"""Transcribe media files file using OpenAI's Whisper model.

This script transcribes audio and video files using the Whisper model from
OpenAI, and creates a .txt file next to the source media file.

See https://github.com/openai/whisper for more information."""

import argparse
import sys
from pathlib import Path

import whisper


def transcribe_file(model, file_path):
    result = model.transcribe(str(file_path))
    return result["text"] if isinstance(result, dict) and "text" in result else result


def get_output_path(input_path):
    return input_path.with_suffix(".txt")


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

    args = parser.parse_args()

    try:
        model = whisper.load_model(args.model)
    except RuntimeError as e:
        print(f"Error loading model '{args.model}': {e}", file=sys.stderr)
        sys.exit(1)

    for file in args.files:
        print(f"Transcribing: {file}")
        try:
            text = transcribe_file(model, file)
            output_path = get_output_path(file)
            output_path.write_text(text, encoding="utf-8")
            print(f"Transcription written to: {output_path}")
        except Exception as e:  # noqa: BLE001
            print(f"Failed to transcribe {file}: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
