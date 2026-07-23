import sys
import time
import shutil
from pathlib import Path
import tkinter as tk
from tkinter import messagebox
from tkinter import ttk

import avif_core


def collect_inputs(args: list[str]) -> list[Path]:
    files: list[Path] = []
    seen: set[str] = set()

    for raw in args:
        path = Path(raw).resolve()
        candidates: list[Path]
        if path.is_dir():
            candidates = avif_core.list_top_level_images(path)
        elif path.is_file() and path.suffix.lower() in avif_core.SUPPORTED_EXTS:
            candidates = [path]
        else:
            continue

        for candidate in candidates:
            key = str(candidate).lower()
            if key not in seen:
                seen.add(key)
                files.append(candidate)

    return files


def main() -> None:
    root = tk.Tk()
    root.withdraw()
    root.update()

    files = collect_inputs(sys.argv[1:])
    if not files:
        messagebox.showerror(
            "AVIF dönüştürme",
            "JPG, JPEG veya PNG dosyası bulunamadı.",
        )
        return

    if len(files) > avif_core.CONFIRM_OVER:
        if not messagebox.askyesno(
            "AVIF dönüştürme",
            f"{len(files)} resim bulundu.\n\nDönüşümden sonra kaynak resimler silinecek. Devam edilsin mi?",
        ):
            return

    win = tk.Toplevel(root)
    win.title("AVIF Dönüştürülüyor")
    win.resizable(False, False)

    title = tk.Label(
        win,
        text="Başarılı dönüşümden sonra kaynak resim silinir.",
        padx=12,
        pady=8,
        anchor="w",
    )
    title.pack(fill="x")

    info = tk.Label(win, text="Hazırlanıyor…", padx=12, pady=4, anchor="w")
    info.pack(fill="x")

    progress = ttk.Progressbar(win, length=520, mode="determinate")
    progress.pack(padx=12, pady=10)

    detail = tk.Label(win, text="", padx=12, pady=4, anchor="w")
    detail.pack(fill="x")

    total = len(files)
    progress["maximum"] = total
    start = time.perf_counter()
    done = 0
    failed: list[str] = []
    output_dirs: set[Path] = set()

    for index, source in enumerate(files, start=1):
        info.config(text=f"Şu an: {source.name}")
        win.update()

        try:
            avif_core.convert_one(source, source.parent)
            done += 1
            output_dirs.add(source.parent)
        except Exception as exc:
            failed.append(f"{source.name}: {exc}")

        progress["value"] = index
        elapsed = time.perf_counter() - start
        remaining = (total - index) * (elapsed / index)
        detail.config(
            text=f"{index}/{total} • Hata: {len(failed)} • ETA: {avif_core.format_eta(remaining)}"
        )
        win.update()

    for output_dir in output_dirs:
        tmp_dir = output_dir / ".avif_tmp"
        if tmp_dir.exists():
            shutil.rmtree(tmp_dir, ignore_errors=True)

    avif_core.short_beep()
    win.destroy()

    if failed:
        preview = "\n".join(failed[:8])
        if len(failed) > 8:
            preview += f"\n… ve {len(failed) - 8} hata daha"
        messagebox.showwarning(
            "AVIF dönüşümü tamamlandı",
            f"Başarılı: {done}\nHatalı: {len(failed)}\n\n{preview}",
        )
    else:
        messagebox.showinfo(
            "AVIF dönüşümü tamamlandı",
            f"{done} resim AVIF'e dönüştürüldü.\nKaynak resimler silindi.",
        )


if __name__ == "__main__":
    main()
