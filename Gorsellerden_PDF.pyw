import re
import sys
from datetime import datetime
from pathlib import Path
import tkinter as tk
from tkinter import messagebox

from PIL import Image

SUPPORTED_EXTS = {".jpg", ".jpeg", ".png"}


def natural_key(path: Path):
    return [int(part) if part.isdigit() else part.lower() for part in re.split(r"(\d+)", path.name)]


def flatten_to_rgb(image: Image.Image) -> Image.Image:
    if image.mode == "RGB":
        return image.copy()
    if image.mode in ("RGBA", "LA") or "transparency" in image.info:
        rgba = image.convert("RGBA")
        background = Image.new("RGB", rgba.size, "white")
        background.paste(rgba, mask=rgba.getchannel("A"))
        return background
    return image.convert("RGB")


def unique_output(parent: Path) -> Path:
    stamp = datetime.now().strftime("%d_%m_%Y__%H_%M_%S")
    candidate = parent / f"Gorseller_{stamp}.pdf"
    number = 2
    while candidate.exists():
        candidate = parent / f"Gorseller_{stamp}_{number}.pdf"
        number += 1
    return candidate


def main() -> None:
    root = tk.Tk()
    root.withdraw()
    root.update()

    files: list[Path] = []
    seen: set[str] = set()
    for raw in sys.argv[1:]:
        path = Path(raw).resolve()
        if path.is_file() and path.suffix.lower() in SUPPORTED_EXTS:
            key = str(path).lower()
            if key not in seen:
                seen.add(key)
                files.append(path)

    if not files:
        messagebox.showerror("Görsellerden PDF", "JPG, JPEG veya PNG seçilmedi.")
        return

    files.sort(key=natural_key)
    output = unique_output(files[0].parent)
    pages: list[Image.Image] = []

    try:
        for path in files:
            with Image.open(path) as image:
                pages.append(flatten_to_rgb(image))

        first, *rest = pages
        first.save(
            output,
            "PDF",
            save_all=True,
            append_images=rest,
            resolution=150.0,
            quality=95,
        )
        messagebox.showinfo(
            "Görsellerden PDF",
            f"PDF oluşturuldu:\n\n{output}\n\nSayfa sayısı: {len(pages)}",
        )
    except Exception as exc:
        messagebox.showerror("Görsellerden PDF", f"PDF oluşturulamadı:\n\n{exc}")
    finally:
        for page in pages:
            try:
                page.close()
            except Exception:
                pass


if __name__ == "__main__":
    main()
