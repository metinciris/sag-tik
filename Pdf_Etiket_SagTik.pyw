import sys
from pathlib import Path
import tkinter as tk
from tkinter import messagebox

import pdf_core


def main() -> None:
    root = tk.Tk()
    root.withdraw()
    root.update()

    if len(sys.argv) < 2:
        messagebox.showerror("PDF etiket aracı", "İşlenecek PDF yolu alınamadı.")
        return

    pdf_path = Path(sys.argv[1]).resolve()
    if not pdf_path.is_file() or pdf_path.suffix.lower() != ".pdf":
        messagebox.showerror("PDF etiket aracı", "Seçilen öğe geçerli bir PDF değil.")
        return

    try:
        written, unread, _, processed = pdf_core.process_single_pdf(
            root,
            str(pdf_path),
            pdf_core.LABEL_MIN_DEFAULT,
            pdf_core.LABEL_MAX_DEFAULT,
            "ask",
        )
        if processed:
            messagebox.showinfo(
                "PDF işlemi tamamlandı",
                f"Yazılan resim: {written}\nEtiketi okunamayan: {unread}",
            )
    except Exception as exc:
        messagebox.showerror("PDF etiket aracı", f"İşlem sırasında hata oluştu:\n\n{exc}")


if __name__ == "__main__":
    main()
