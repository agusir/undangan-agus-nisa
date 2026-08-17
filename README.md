# Undangan Pernikahan — Agus & Nisa

Undangan digital 1 halaman. Tanpa framework, tanpa build — cukup `index.html` + folder `foto/`.

**Akad Nikah:** Jumat, 11 September 2026 · 08.00 WIB · Rumah Mempelai Wanita
**Tasyakuran:** Kamis, 10 September 2026 · Waktu bebas · Rumah Mempelai Pria

---

## Tes di lokal

```bash
cd ~/Downloads/undangan-agus-nisa
python3 -m http.server 8080
```
Lalu buka <http://localhost:8080>

> Pakai server lokal (bukan klik dobel file) supaya perilakunya sama persis
> seperti nanti setelah online — termasuk musik, simpan ucapan, dan pemuatan foto.

**Undangan per tamu:** tambahkan `?to=` di belakang URL —
`http://localhost:8080/?to=Bapak%20Budi` → nama tamu muncul otomatis di cover.

---

## Isi folder

```
index.html            undangan (semua CSS & JS menyatu di dalamnya)
optimize-foto.sh      skrip kompres foto (sudah dijalankan)
foto/
  cover.*             layar pembuka          (IMG_5964)
  hero.*              latar samar bagian atas (IMG_5962)
  pria.*              mempelai pria           (IMG_5984)
  wanita.*            mempelai wanita         (IMG_5970)
  galeri-1..4.*       galeri                  (6033, 5951, 6011, 6020)
  penutup.*           foto penutup            (IMG_5992)
  og-cover.jpg        gambar preview WhatsApp (1200×630)
```
Tiap foto punya `.webp` (dipakai browser modern, ±60% lebih kecil) dan `.jpg` (cadangan).
Foto asli 149 file tetap utuh di `~/Downloads/Prewed` — tidak diubah.

---

## Yang masih perlu diganti

Cari kata `EDIT:` di `index.html`:

1. **Nomor rekening** — sekarang masih contoh
   (`1010 2020 3030` Bank Jago · `0123456789` BNI)
2. **Alamat situs** di bagian meta — hanya kalau nanti pindah dari GitHub Pages

---

## Ganti foto sendiri

Timpa file di `foto/` dengan nama yang sama (mis. `pria.jpg` + `pria.webp`).
Atau ubah daftar di `optimize-foto.sh` lalu jalankan `bash optimize-foto.sh`.

---

## Musik

Sekarang memakai **rekaman gamelan Jawa asli** (bukan suara sintetis).

| File | Judul | Durasi | Ukuran | Lisensi |
|---|---|---|---|---|
| `audio/gamelan-kraton.m4a` **(dipakai)** | Gamelan Kraton Ngayogyakarta — abdi dalem Keraton Yogyakarta | 2:14 | 1,0 MB | CC BY 4.0 (RTB45) |
| `audio/gamelan-nyawiji.m4a` (cadangan) | Gending Nyawiji — *nyawiji* = menyatu | 4:31 | 2,1 MB | CC BY-SA 4.0 (Sanggar Seni Laras Siwi) |

**Ganti lagu:** buka `index.html`, cari `const MUSIC_FILE`, ganti isinya ke
`"audio/gamelan-nyawiji.m4a"` — atau taruh file sendiri di `audio/` lalu tulis namanya di situ.
Kalau ganti ke Nyawiji, **ubah juga baris kredit di footer** (lisensinya CC BY-SA, penciptanya beda).

### Pakai lagu pop Jawa sendiri (Nemen / Jajalen Aku / Loro Ati, dll.)

Siapkan file lagunya (mp3/m4a/wav — dari koleksimu sendiri), lalu potong bagian
refrain-nya saja supaya ringan:

```bash
# bash potong-lagu.sh <file-lagu> <detik-mulai> <durasi>
bash potong-lagu.sh ~/Downloads/nemen.mp3 62 45
```
Artinya: ambil **45 detik** mulai dari **detik ke-62** (menit 1:02).
Hasilnya `audio/lagu.m4a` — sudah AAC mono 64 kbps, ±350 KB, plus **fade in/out
1,5 detik** di ujungnya supaya sambungan saat mengulang terdengar mulus.

Lalu ubah di `index.html`:
```js
const MUSIC_FILE = "audio/lagu.m4a";
```
Dan **hapus baris kredit gamelan di footer** (tidak berlaku lagi).

> ⚠️ Lagu komersial (Gilga Sahid, Denny Caknan, Aftershine, dll.) **berhak cipta**.
> Memakainya di situs yang bisa diakses publik secara teknis melanggar, meski
> untuk undangan pribadi risikonya kecil. Pertimbangkan sendiri, atau pakai
> gamelan berlisensi bebas yang sudah disediakan di atas.

Catatan teknis:
- Format **`.m4a` (AAC)** dipilih karena jalan di **semua** browser termasuk Safari/iPhone.
  File `.ogg` asli dari Wikimedia tidak bisa diputar di iOS.
- Di-encode ulang jadi mono 64 kbps supaya ringan (dari 4 MB → 1 MB).
- Musik mulai saat tamu menekan **"Buka Undangan"** (kebijakan browser melarang
  suara berjalan otomatis), dan volumenya naik perlahan biar tidak mengagetkan.
- Kalau file gagal dimuat, otomatis jatuh ke gamelan laras **slendro** sintetis
  yang dibangkitkan browser — jadi tetap ada musik.
- **Kredit di footer wajib ada** selama memakai berkas CC BY ini. Jangan dihapus.

---

## Cara online-kan (GitHub Pages) — nanti, setelah puas dengan hasil tes

```bash
cd ~/Downloads/undangan-agus-nisa
git init && git add -A && git commit -m "undangan pernikahan Agus & Nisa"
gh repo create undangan-agus-nisa --public --source=. --push
gh api -X POST repos/agusir/undangan-agus-nisa/pages -f build_type=legacy \
  -F 'source[branch]=main' -F 'source[path]=/'
```
Hasil: <https://agusir.github.io/undangan-agus-nisa/>

Catatan: repo harus **public** (syarat GitHub Pages gratis) — isi undangan termasuk
alamat rumah bisa dilihat publik di GitHub. Kalau keberatan, pakai Netlify
(gratis juga, repo tidak perlu publik).

**Preview WhatsApp** baru muncul setelah online — butuh URL publik, tidak bisa dites di lokal.
