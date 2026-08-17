#!/bin/bash
# Kompres 9 foto prewed terpilih (versi editan) -> WebP + fallback JPG.
# Sumber tidak diubah. Jalankan sekali: bash optimize-foto.sh
set -e

SRC="$HOME/Downloads/Prewed"
OUT="$(cd "$(dirname "$0")" && pwd)/foto"
mkdir -p "$OUT"

# nama_keluaran : file_sumber : sisi_terpanjang(px) : kualitas
JOBS="
cover:IMG_5964:1600:80
hero:IMG_5962:1400:78
pria:IMG_5984:1200:80
wanita:IMG_5970:1200:80
galeri-1:IMG_6033:1000:78
galeri-2:IMG_5951:1000:78
galeri-3:IMG_6011:1000:78
galeri-4:IMG_6020:1000:78
penutup:IMG_5992:1200:80
"

echo "== Kompres foto =="
for job in $JOBS; do
  [ -z "$job" ] && continue
  name=$(echo "$job" | cut -d: -f1)
  src=$(echo "$job"  | cut -d: -f2)
  size=$(echo "$job" | cut -d: -f3)
  q=$(echo "$job"    | cut -d: -f4)
  in="$SRC/$src.jpg.jpeg"

  [ -f "$in" ] || { echo "  ! lewat: $in tidak ada"; continue; }

  # JPG fallback (sekaligus jadi sumber untuk WebP)
  sips -Z "$size" -s format jpeg -s formatOptions "$q" "$in" --out "$OUT/$name.jpg" >/dev/null
  # WebP
  cwebp -q "$q" -quiet "$OUT/$name.jpg" -o "$OUT/$name.webp"

  wj=$(du -k "$OUT/$name.jpg"  | cut -f1)
  ww=$(du -k "$OUT/$name.webp" | cut -f1)
  echo "  $name  <- $src   jpg ${wj}KB / webp ${ww}KB"
done

echo ""
echo "Total folder foto:"; du -sh "$OUT"
