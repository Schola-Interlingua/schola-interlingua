#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VOCAB_PATH = ROOT / "flutter_app" / "assets" / "data" / "vocab.json"
OUTPUT_DIR = ROOT / "flutter_app" / "assets" / "audios" / "interlingua"
MANIFEST_PATH = OUTPUT_DIR / "manifest.json"


def normalize_option_text(text: str) -> str:
    normalized = text.strip().lower()
    replacements = str.maketrans(
        {
            "á": "a",
            "à": "a",
            "ä": "a",
            "â": "a",
            "ã": "a",
            "é": "e",
            "è": "e",
            "ë": "e",
            "ê": "e",
            "í": "i",
            "ì": "i",
            "ï": "i",
            "î": "i",
            "ó": "o",
            "ò": "o",
            "ö": "o",
            "ô": "o",
            "õ": "o",
            "ú": "u",
            "ù": "u",
            "ü": "u",
            "û": "u",
            "ñ": "n",
            "ç": "c",
        }
    )
    normalized = normalized.translate(replacements)
    normalized = re.sub(r"[^a-z0-9]+", "_", normalized)
    normalized = re.sub(r"_+", "_", normalized)
    return normalized.strip("_")


def load_unique_terms() -> list[str]:
    data = json.loads(VOCAB_PATH.read_text())
    terms = {
        (item.get("term") or "").strip()
        for items in data.values()
        for item in items
        if (item.get("term") or "").strip()
    }
    return sorted(terms, key=str.lower)


def ensure_tool(name: str) -> None:
    result = subprocess.run(
        ["bash", "-lc", f"command -v {name} >/dev/null 2>&1"],
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(f"Missing required tool: {name}")


def generate_wav(text: str, destination: Path, voice: str) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        aiff_path = Path(tmpdir) / "temp.aiff"
        subprocess.run(
            ["say", "-v", voice, "-o", str(aiff_path), text],
            check=True,
        )
        subprocess.run(
            [
                "afconvert",
                "-f",
                "WAVE",
                "-d",
                "LEI16@22050",
                "-c",
                "1",
                str(aiff_path),
                str(destination),
            ],
            check=True,
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate bundled Interlingua audio assets from vocab.json.",
    )
    parser.add_argument(
        "--voice",
        default="Flo (Spanish (Spain))",
        help="macOS say voice to use for generation.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Regenerate existing files too.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Generate only the first N entries for quick verification.",
    )
    args = parser.parse_args()

    ensure_tool("say")
    ensure_tool("afconvert")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    terms = load_unique_terms()
    if args.limit > 0:
        terms = terms[: args.limit]
    manifest: list[dict[str, str]] = []
    generated = 0
    skipped = 0

    for term in terms:
        filename = normalize_option_text(term)
        if not filename:
            continue
        output_path = OUTPUT_DIR / f"{filename}.wav"
        manifest.append({"text": term, "filename": output_path.name})
        if output_path.exists() and not args.force:
            skipped += 1
            continue
        generate_wav(term, output_path, args.voice)
        generated += 1
        print(f"generated {output_path.name}")

    MANIFEST_PATH.write_text(
        json.dumps(
            {
                "voice": args.voice,
                "count": len(manifest),
                "entries": manifest,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n"
    )

    print(
        f"done: {len(manifest)} entries, {generated} generated, {skipped} skipped",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
