#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import OrderedDict
from pathlib import Path

try:
    import genanki
except ImportError as exc:  # pragma: no cover - CLI guard
    raise SystemExit(
        "Missing dependency: genanki. Install it with `pip3 install --user genanki`."
    ) from exc


ROOT = Path(__file__).resolve().parents[1]
VOCAB_PATH = ROOT / "flutter_app" / "assets" / "data" / "vocab.json"
COURSE_SEED_PATH = ROOT / "flutter_app" / "lib" / "src" / "data" / "course_seed.dart"
AUDIO_DIR = ROOT / "flutter_app" / "assets" / "audios" / "interlingua"
AUDIO_MANIFEST_PATH = AUDIO_DIR / "manifest.json"
OUTPUT_DIR = ROOT / "flutter_app" / "assets" / "apkg"
OUTPUT_MANIFEST_PATH = OUTPUT_DIR / "manifest.json"

ROOT_DECK_NAME = "Schola Interlingua"
SUPPORTED_LANGUAGES = OrderedDict(
    [
        ("es", "Español"),
        ("en", "English"),
        ("ru", "Русский"),
        ("de", "Deutsch"),
        ("fr", "Français"),
        ("it", "Italiano"),
        ("la", "Lingua Latina"),
        ("eo", "Esperanto"),
        ("pt", "Português"),
        ("zh", "中文"),
        ("ja", "日本語"),
        ("ca", "Català"),
        ("ko", "한국어"),
    ]
)


def stable_int(seed: str, digits: int = 12) -> int:
    digest = hashlib.sha1(seed.encode("utf-8")).hexdigest()
    return int(digest[:digits], 16)


def stable_guid(*parts: str) -> str:
    joined = "\x1f".join(parts)
    return hashlib.sha1(joined.encode("utf-8")).hexdigest()[:20]


def normalize_audio_filename(text: str) -> str:
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


def load_course_vocab_groups() -> list[dict[str, str]]:
    lines = COURSE_SEED_PATH.read_text().splitlines()
    stack: list[str] = []
    current_level: dict[str, str] = {}
    current_section: dict[str, str] = {}
    current_item: dict[str, str] = {}
    groups: list[dict[str, str]] = []

    for raw_line in lines:
        line = raw_line.strip()
        if line.startswith("CourseLevel("):
            stack.append("level")
            current_level = {}
            continue
        if line.startswith("CourseSection("):
            stack.append("section")
            current_section = {}
            continue
        if line.startswith("CourseItemRef("):
            stack.append("item")
            current_item = {}
            continue

        slug_match = re.match(r"slug: '([^']+)'", line)
        if slug_match:
            if stack and stack[-1] == "level":
                current_level["slug"] = slug_match.group(1)
            elif stack and stack[-1] == "item":
                current_item["slug"] = slug_match.group(1)
            continue

        title_match = re.match(r"title: '([^']+)'", line)
        if title_match:
            if stack and stack[-1] == "level":
                current_level["title"] = title_match.group(1)
            elif stack and stack[-1] == "section":
                current_section["title"] = title_match.group(1)
            elif stack and stack[-1] == "item":
                current_item["title"] = title_match.group(1)
            continue

        kind_match = re.match(
            r"kind: (LevelSectionKind\.[a-zA-Z0-9_]+|CourseItemKind\.[a-zA-Z0-9_]+)",
            line,
        )
        if kind_match:
            kind = kind_match.group(1)
            if stack and stack[-1] == "section":
                current_section["kind"] = kind
            elif stack and stack[-1] == "item":
                current_item["kind"] = kind
            continue

        if line == "),":
            if not stack:
                continue
            ended = stack.pop()
            if ended == "item":
                if (
                    current_section.get("kind") == "LevelSectionKind.vocabulario"
                    and current_item.get("kind") == "CourseItemKind.vocabulary"
                ):
                    groups.append(
                        {
                            "levelSlug": current_level["slug"],
                            "levelTitle": current_level["title"],
                            "sourceSlug": current_item["slug"],
                            "sourceTitle": current_item["title"],
                        }
                    )
                current_item = {}
            elif ended == "section":
                current_section = {}
            elif ended == "level":
                current_level = {}

    return groups


def load_vocab() -> dict[str, list[dict[str, str]]]:
    raw = json.loads(VOCAB_PATH.read_text())
    result: dict[str, list[dict[str, str]]] = {}
    for slug, items in raw.items():
        parsed_items: list[dict[str, str]] = []
        for item in items:
            if not isinstance(item, dict):
                continue
            parsed = {
                str(key): str(value).strip()
                for key, value in item.items()
                if value is not None and str(value).strip()
            }
            if parsed.get("term"):
                parsed_items.append(parsed)
        result[str(slug)] = parsed_items
    return result


def load_audio_entries() -> dict[str, str]:
    manifest = json.loads(AUDIO_MANIFEST_PATH.read_text())
    return {
        entry["text"].strip(): entry["filename"]
        for entry in manifest["entries"]
        if entry.get("text") and entry.get("filename")
    }


def build_model() -> genanki.Model:
    return genanki.Model(
        stable_int("schola-interlingua-apkg-model", digits=8),
        "Schola Interlingua Vocabulary",
        fields=[
            {"name": "Interlingua"},
            {"name": "Translation"},
            {"name": "Audio"},
            {"name": "Level"},
            {"name": "Vocabulary"},
        ],
        templates=[
            {
                "name": "Recognition",
                "qfmt": """
<div class="term">{{Interlingua}}</div>
<div class="audio">{{Audio}}</div>
<div class="meta">{{Level}} · {{Vocabulary}}</div>
""",
                "afmt": """
{{FrontSide}}
<hr id="answer">
<div class="translation">{{Translation}}</div>
""",
            }
        ],
        css="""
.card {
  font-family: Arial, sans-serif;
  text-align: center;
  color: #122033;
  background: #f8fbff;
  padding: 28px 20px;
}
.term {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 16px;
}
.audio {
  margin-bottom: 18px;
}
.translation {
  font-size: 24px;
  font-weight: 600;
}
.meta {
  margin-top: 10px;
  font-size: 14px;
  color: #47607c;
}
hr#answer {
  border: 0;
  border-top: 1px solid #c7d8eb;
  margin: 20px 0;
}
""",
    )


def build_package_for_language(language: str) -> dict[str, object]:
    if language not in SUPPORTED_LANGUAGES:
        raise SystemExit(f"Unsupported language: {language}")

    vocab = load_vocab()
    audio_entries = load_audio_entries()
    groups = load_course_vocab_groups()
    model = build_model()

    decks: dict[str, genanki.Deck] = {}
    media_files: set[str] = set()
    note_count = 0
    used_levels: set[str] = set()
    used_sources: set[str] = set()

    for group in groups:
        source_slug = group["sourceSlug"]
        items = vocab.get(source_slug, [])
        if not items:
            continue

        deck_name = (
            f"{ROOT_DECK_NAME}::{group['levelTitle']}::{group['sourceTitle']}"
        )
        deck = decks.get(deck_name)
        if deck is None:
            deck = genanki.Deck(
                stable_int(f"deck:{deck_name}", digits=8),
                deck_name,
                description=(
                    f"Vocabulario de {group['sourceTitle']} "
                    f"({group['levelTitle']}) in {SUPPORTED_LANGUAGES[language]}."
                ),
            )
            decks[deck_name] = deck

        for item in items:
            term = item.get("term", "").strip()
            translation = item.get(language, "").strip()
            if not term or not translation:
                continue

            audio_filename = audio_entries.get(term)
            if audio_filename is None:
                fallback_name = normalize_audio_filename(term)
                fallback_file = f"{fallback_name}.wav"
                if fallback_name and (AUDIO_DIR / fallback_file).exists():
                    audio_filename = fallback_file
            audio_field = ""
            if audio_filename:
                media_path = AUDIO_DIR / audio_filename
                if media_path.exists():
                    media_files.add(str(media_path))
                    audio_field = f"[sound:{audio_filename}]"

            tags = [
                f"lang:{language}",
                f"level:{group['levelSlug']}",
                f"source:{group['sourceSlug']}",
            ]
            note = genanki.Note(
                model=model,
                fields=[
                    term,
                    translation,
                    audio_field,
                    group["levelTitle"],
                    group["sourceTitle"],
                ],
                tags=tags,
                guid=stable_guid(language, group["sourceSlug"], term, translation),
            )
            deck.add_note(note)
            note_count += 1
            used_levels.add(group["levelTitle"])
            used_sources.add(group["sourceTitle"])

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / f"schola-interlingua-{language}.apkg"
    genanki.Package(
        list(decks.values()),
        media_files=sorted(media_files),
    ).write_to_file(str(output_path))

    return {
        "language": language,
        "label": SUPPORTED_LANGUAGES[language],
        "file": output_path.name,
        "assetPath": f"assets/apkg/{output_path.name}",
        "noteCount": note_count,
        "levelCount": len(used_levels),
        "sourceCount": len(used_sources),
        "sizeBytes": output_path.stat().st_size,
    }


def write_manifest(entries: list[dict[str, object]]) -> None:
    manifest = {
        "deckName": ROOT_DECK_NAME,
        "structure": "level-source",
        "languages": {entry["language"]: entry for entry in entries},
    }
    OUTPUT_MANIFEST_PATH.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate Anki .apkg exports with audio for Schola Interlingua.",
    )
    parser.add_argument(
        "--language",
        dest="languages",
        action="append",
        choices=list(SUPPORTED_LANGUAGES.keys()),
        help="Generate only one language. Repeat the flag to build several.",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Generate packages for all supported translation languages.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    languages = args.languages or []
    if args.all:
        languages = list(SUPPORTED_LANGUAGES.keys())
    if not languages:
        languages = ["es"]

    built_entries: list[dict[str, object]] = []
    for language in languages:
        entry = build_package_for_language(language)
        built_entries.append(entry)
        print(
            f"built {entry['file']} "
            f"({entry['noteCount']} notes, {entry['sizeBytes']} bytes)"
        )

    write_manifest(built_entries)
    print(
        f"wrote manifest with {len(built_entries)} package(s) to "
        f"{OUTPUT_MANIFEST_PATH.relative_to(ROOT)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
