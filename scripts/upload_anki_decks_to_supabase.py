#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_URL = os.environ.get("SUPABASE_URL", "https://redvymknnxehwveyzmyw.supabase.co")
SERVICE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or os.environ.get(
    "SUPABASE_SECRET_KEY"
)
BUCKET = os.environ.get("SUPABASE_ANKI_BUCKET", "anki-decks")
PREFIX = os.environ.get("SUPABASE_ANKI_PREFIX", "anki")
LOCAL_DECK_DIR = ROOT / "flutter_app" / "assets" / "apkg"
LOCAL_MANIFEST = ROOT / "flutter_app" / "assets" / "data" / "anki_manifest.json"


def require_service_key() -> str:
    if SERVICE_KEY:
        return SERVICE_KEY
    raise SystemExit(
        "Missing SUPABASE_SERVICE_ROLE_KEY or SUPABASE_SECRET_KEY in the environment."
    )


def request(method: str, url: str, body: bytes | None = None, content_type: str | None = None) -> bytes:
    headers = {
        "Authorization": f"Bearer {require_service_key()}",
        "apikey": require_service_key(),
    }
    if content_type:
        headers["Content-Type"] = content_type
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.read()
    except urllib.error.HTTPError as exc:
        payload = exc.read().decode("utf-8", errors="replace")
        raise SystemExit(f"{method} {url} failed: {exc.code} {payload}") from exc


def ensure_bucket() -> None:
    payload = json.dumps(
        {
            "id": BUCKET,
            "name": BUCKET,
            "public": True,
            "file_size_limit": 104857600,
            "allowed_mime_types": ["application/octet-stream", "application/json"],
        }
    ).encode("utf-8")
    try:
        request("POST", f"{PROJECT_URL}/storage/v1/bucket", payload, "application/json")
        print(f"created bucket {BUCKET}")
    except SystemExit as exc:
        if "Duplicate" in str(exc) or "already exists" in str(exc):
            print(f"bucket {BUCKET} already exists")
            return
        raise


def upload_file(local_path: Path, remote_path: str, content_type: str) -> None:
    encoded_path = urllib.parse.quote(remote_path, safe="/")
    url = f"{PROJECT_URL}/storage/v1/object/{BUCKET}/{encoded_path}"
    body = local_path.read_bytes()
    headers_body = body
    headers_type = content_type
    headers = {
        "Authorization": f"Bearer {require_service_key()}",
        "apikey": require_service_key(),
        "Content-Type": headers_type,
        "x-upsert": "true",
    }
    req = urllib.request.Request(url, data=headers_body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            resp.read()
    except urllib.error.HTTPError as exc:
        payload = exc.read().decode("utf-8", errors="replace")
        raise SystemExit(f"upload {remote_path} failed: {exc.code} {payload}") from exc
    print(f"uploaded {remote_path}")


def main() -> int:
    ensure_bucket()
    manifest = json.loads(LOCAL_MANIFEST.read_text())
    for language, entry in manifest["languages"].items():
        local_path = LOCAL_DECK_DIR / entry["file"]
        remote_path = entry.get("objectPath") or f"{PREFIX}/{entry['file']}"
        upload_file(local_path, remote_path, "application/octet-stream")
        print(f"ready: {language} -> {remote_path}")

    upload_file(LOCAL_MANIFEST, f"{PREFIX}/manifest.json", "application/json")
    public_url = (
        f"{PROJECT_URL}/storage/v1/object/public/{BUCKET}/{PREFIX}/manifest.json"
    )
    print(f"manifest uploaded to {public_url}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
