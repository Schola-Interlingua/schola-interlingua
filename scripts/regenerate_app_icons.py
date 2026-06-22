#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_LOGO = ROOT / "flutter_app" / "assets" / "images" / "logo.png"


def load_foreground() -> tuple[Image.Image, tuple[int, int, int]]:
    source = Image.open(SOURCE_LOGO).convert("RGBA")
    bg_color = source.getpixel((0, 0))[:3]
    foreground = Image.new("RGBA", source.size)

    for y in range(source.height):
      for x in range(source.width):
        r, g, b, a = source.getpixel((x, y))
        distance = (
            (r - bg_color[0]) ** 2
            + (g - bg_color[1]) ** 2
            + (b - bg_color[2]) ** 2
        ) ** 0.5
        if distance < 18:
            foreground.putpixel((x, y), (0, 0, 0, 0))
        elif distance < 40:
            alpha = int((distance - 18) / 22 * 255)
            foreground.putpixel((x, y), (r, g, b, alpha))
        else:
            foreground.putpixel((x, y), (r, g, b, a))

    return foreground, bg_color


def make_icon(
    foreground: Image.Image,
    bg_color: tuple[int, int, int],
    size: int,
    scale: float,
    transparent_background: bool = False,
) -> Image.Image:
    background = (0, 0, 0, 0) if transparent_background else (*bg_color, 255)
    canvas = Image.new("RGBA", (size, size), background)
    icon_size = int(size * scale)
    resized = foreground.resize((icon_size, icon_size), Image.LANCZOS)
    offset = ((size - icon_size) // 2, (size - icon_size) // 2)
    canvas.alpha_composite(resized, offset)
    return canvas


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG")


def main() -> int:
    foreground, bg_color = load_foreground()

    regular_master = make_icon(foreground, bg_color, 1024, 0.76)
    maskable_master = make_icon(foreground, bg_color, 1024, 0.62)

    save_png(regular_master, ROOT / "flutter_app/assets/images/logo_app_icon_master.png")
    save_png(maskable_master, ROOT / "flutter_app/assets/images/logo_app_icon_maskable.png")

    web_regular_sizes = {
        ROOT / "flutter_app/web/icons/Icon-192.png": 192,
        ROOT / "flutter_app/web/icons/Icon-512.png": 512,
        ROOT / "public/icons/Icon-192.png": 192,
        ROOT / "public/icons/Icon-512.png": 512,
    }
    for path, size in web_regular_sizes.items():
        save_png(regular_master.resize((size, size), Image.LANCZOS), path)

    web_maskable_sizes = {
        ROOT / "flutter_app/web/icons/Icon-maskable-192.png": 192,
        ROOT / "flutter_app/web/icons/Icon-maskable-512.png": 512,
        ROOT / "public/icons/Icon-maskable-192.png": 192,
        ROOT / "public/icons/Icon-maskable-512.png": 512,
    }
    for path, size in web_maskable_sizes.items():
        save_png(maskable_master.resize((size, size), Image.LANCZOS), path)

    favicon_sizes = {
        ROOT / "flutter_app/web/favicon.png": 48,
        ROOT / "public/favicon.png": 48,
    }
    for path, size in favicon_sizes.items():
        save_png(regular_master.resize((size, size), Image.LANCZOS), path)

    play_store_icons = {
        ROOT / "play_store_assets/schola-playstore-icon-512.png": 512,
        ROOT / "play_store_assets/schola-playstore-icon-512-v2.png": 512,
    }
    for path, size in play_store_icons.items():
        save_png(regular_master.resize((size, size), Image.LANCZOS), path)

    android_regular_sizes = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    android_foreground_scales = {
        "mdpi": 0.72,
        "hdpi": 0.72,
        "xhdpi": 0.72,
        "xxhdpi": 0.72,
        "xxxhdpi": 0.72,
    }
    for density, size in android_regular_sizes.items():
        regular_path = ROOT / f"flutter_app/android/app/src/main/res/mipmap-{density}/ic_launcher.png"
        round_path = ROOT / f"flutter_app/android/app/src/main/res/mipmap-{density}/ic_launcher_round.png"
        foreground_path = ROOT / f"flutter_app/android/app/src/main/res/mipmap-{density}/ic_launcher_foreground.png"
        save_png(regular_master.resize((size, size), Image.LANCZOS), regular_path)
        save_png(regular_master.resize((size, size), Image.LANCZOS), round_path)
        fg = make_icon(
            foreground,
            bg_color,
            size,
            android_foreground_scales[density],
            transparent_background=True,
        )
        save_png(fg, foreground_path)

    ios_icons = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    ios_dir = ROOT / "flutter_app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in ios_icons.items():
        save_png(regular_master.resize((size, size), Image.LANCZOS), ios_dir / filename)

    macos_icons = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    macos_dir = ROOT / "flutter_app/macos/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in macos_icons.items():
        save_png(regular_master.resize((size, size), Image.LANCZOS), macos_dir / filename)

    print("Regenerated app icons with a single blue background and clean foreground.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
