#!/bin/bash
# Potong lagu jadi cuplikan pendek (refrain) + kompres untuk web.
#
#   bash potong-lagu.sh <file-lagu> [detik-mulai] [durasi-detik]
#
# Contoh — ambil 45 detik mulai dari menit 1:02 :
#   bash potong-lagu.sh ~/Downloads/nemen.mp3 62 45
#
# Hasil: audio/lagu.m4a  (AAC mono 64 kbps — jalan di semua HP termasuk iPhone)
# Lalu buka index.html, cari  const MUSIC_FILE  → ganti jadi "audio/lagu.m4a"
set -e

SRC="$1"; START="${2:-0}"; DUR="${3:-45}"
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/audio/lagu.m4a"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

[ -z "$SRC" ] && { echo "Pakai: bash potong-lagu.sh <file-lagu> [detik-mulai] [durasi]"; exit 1; }
[ -f "$SRC" ] || { echo "File tidak ditemukan: $SRC"; exit 1; }
mkdir -p "$DIR/audio"

echo "→ Membaca  : $SRC"
echo "→ Ambil    : detik $START, selama $DUR detik"

# 1) apa pun formatnya (mp3/m4a/wav/aac) → WAV mono 44.1kHz
afconvert -f WAVE -d LEI16 --mix -c 1 -r 44100 "$SRC" "$TMP/full.wav"

# 2) potong + fade in/out 1,5 detik (biar sambungan loop-nya halus)
#    Baca RIFF manual — afconvert menulis WAVE_FORMAT_EXTENSIBLE yang
#    tidak dikenali modul `wave` bawaan Python.
python3 - "$TMP/full.wav" "$TMP/cut.wav" "$START" "$DUR" << 'PY'
import sys, struct
src, dst, start, dur = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
raw = open(src, 'rb').read()

# telusuri chunk RIFF: ambil 'fmt ' (format) dan 'data' (isi)
pos, fmt, data = 12, None, None
while pos + 8 <= len(raw):
    cid  = raw[pos:pos+4]
    size = struct.unpack_from('<I', raw, pos+4)[0]
    body = raw[pos+8:pos+8+size]
    if cid == b'fmt ':  fmt = body
    elif cid == b'data': data = body
    pos += 8 + size + (size & 1)          # chunk selalu rata 2 byte
if fmt is None or data is None:
    sys.exit("WAV tidak terbaca (chunk fmt/data tidak ketemu).")

ch, sr = struct.unpack_from('<HI', fmt, 2)
bits   = struct.unpack_from('<H', fmt, 14)[0]
if bits != 16:
    sys.exit(f"Perlu 16-bit PCM, dapatnya {bits}-bit.")

frame = ch * 2                                   # byte per frame
total = len(data) / frame / sr
if start >= total:
    sys.exit(f"Lagunya cuma {total:.0f} detik — mulai detik {start:.0f} tidak ada isinya.")

a = int(start * sr) * frame
b = min(a + int(dur * sr) * frame, len(data))
s = list(struct.unpack("<%dh" % ((b-a)//2), data[a:b]))

fade = int(1.5 * sr) * ch                        # 1,5 detik
for i in range(min(fade, len(s))):
    s[i]      = int(s[i] * (i / fade))           # fade in
    s[-1-i]   = int(s[-1-i] * (i / fade))        # fade out

pcm = struct.pack("<%dh" % len(s), *s)
hdr = (b'RIFF' + struct.pack('<I', 36 + len(pcm)) + b'WAVEfmt ' +
       struct.pack('<IHHIIHH', 16, 1, ch, sr, sr*frame, frame, 16) +
       b'data' + struct.pack('<I', len(pcm)))
open(dst, 'wb').write(hdr + pcm)
print(f"   durasi asli {total:.0f}s → cuplikan {len(s)/ch/sr:.0f}s")
PY

# 3) WAV → AAC mono 64 kbps
afconvert -f m4af -d aac -b 64000 "$TMP/cut.wav" "$OUT"

echo "✓ Jadi     : audio/lagu.m4a  ($(du -h "$OUT" | cut -f1))"
echo ""
echo "Langkah terakhir: buka index.html, cari  const MUSIC_FILE"
echo "lalu ubah jadi:   const MUSIC_FILE = \"audio/lagu.m4a\";"
