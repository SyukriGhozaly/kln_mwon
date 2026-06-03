# DESIGN.md

## Konsep Desain
Aplikasi Klinik Mawon adalah aplikasi mobile booking klinik online dengan tampilan bersih, ringan, modern, dan ramah pasien. Desain mengikuti Figma yang sudah dibuat: dominan putih dan biru muda, card rounded, icon sederhana, serta layout mobile yang mudah dipahami.

## Identitas Visual

### Nama Aplikasi
Klinik Mawon

### Tema
- Medical
- Clean
- Friendly
- Simple
- Modern

### Warna Utama
Primary Blue:
#2F80ED

Light Blue:
#EAF5FF

Background:
#F5F5F5 atau #F8FBFF

White:
#FFFFFF

Text Dark:
#1F2937

Text Grey:
#6B7280

Success:
#22C55E

Warning:
#F59E0B

Danger:
#EF4444

## Font
Gunakan font default Flutter atau Poppins jika tersedia.

Rekomendasi:
- Title: Poppins SemiBold / Bold
- Body: Poppins Regular
- Button: Poppins Medium

Jika Poppins belum dipasang, pakai font default dulu.

## Ukuran Umum
- Border radius card: 12 - 20
- Border radius button: 10 - 14
- Padding halaman: 16
- Jarak antar card: 12 - 16
- Tinggi tombol utama: 48 - 52
- Icon bottom nav: 22 - 26

## Style Komponen

### Button Utama
- Background biru
- Text putih
- Rounded
- Full width jika untuk aksi utama
- Contoh teks:
  - SIGN UP
  - LOGIN
  - DAFTAR
  - PAYMENT
  - SAVE

### Button Secondary
- Background putih
- Border biru muda
- Text biru
- Rounded

### TextField
- Background putih atau biru sangat muda
- Border rounded
- Label kecil
- Hint abu-abu
- Gunakan icon jika perlu

### Card
- Background putih
- Rounded 16
- Shadow halus
- Padding 12-16
- Jangan terlalu ramai

### Bottom Navigation
Menu:
1. Home
2. Jadwal / Dokter
3. Booking / Pembayaran
4. Riwayat
5. Profil

Style:
- Icon aktif warna biru
- Icon nonaktif abu-abu
- Label kecil
- Background putih

## Halaman Berdasarkan Figma

### Splash Screen
Isi:
- Logo / icon klinik di tengah
- Nama Klinik Mawon
- Background putih
- Bisa tambah loading kecil

### Login
Layout:
- Logo di atas
- Judul "Klinik Mawon"
- Subtitle "Sistem Booking Klinik Online"
- Input email
- Input password
- Link lupa password
- Tombol SIGN IN
- Divider "or sign in with"
- Icon Google dan Facebook
- Link daftar akun

Style:
- Card form biru muda
- Tombol biru
- Rounded

### Register
Layout:
- Judul "Daftar Akun"
- Input nama lengkap
- Email
- No HP
- Password
- Konfirmasi password
- Tombol DAFTAR
- Link login

### Home
Layout:
- Header sapaan:
  "Hi, [Nama User]"
  "Pilih layanan kesehatanmu"
- Banner informasi klinik
- Menu cepat dalam grid/card
- Section "Daftar Dokter"
- Section "Jadwal Terdekat"

Card dokter:
- Foto dokter
- Nama dokter
- Spesialis
- Tombol detail / booking

### Jadwal Dokter
Layout:
- AppBar "Pelayanan Klinik" atau "Jadwal Dokter"
- List card dokter/poli
- Setiap card berisi icon/foto, nama layanan, jam praktik, tombol panah

### Informasi Jadwal Dokter
Layout:
- Card dokter
- Jadwal praktik
- Tanggal praktik
- Jam praktik
- Status tersedia
- Tombol booking

### Konfirmasi Jadwal
Layout:
- Ringkasan pasien
- Ringkasan dokter
- Jadwal
- Lokasi klinik
- Tombol PAYMENT

### Pembayaran
Layout:
- Total tagihan
- Kode booking
- QRIS atau gambar pembayaran
- Metode pembayaran
- Tombol konfirmasi

### Kode Antrian / Tiket
Layout:
- Icon success
- Teks "Pendaftaran Berhasil"
- Nomor antrian besar
- QR Code
- Detail booking
- Tombol kembali ke home

### Riwayat
Layout:
- List booking
- Status dalam badge
- Detail tanggal dan dokter
- Tombol lihat detail

### Profil
Layout:
- Foto profil di atas
- Nama user
- Email
- Menu list:
  - Edit Profil
  - Riwayat
  - Pengaturan
  - Bantuan
  - Logout

### Edit Profil
Layout:
- Foto profil
- Input nama
- Email
- No HP
- Alamat
- Tombol SAVE

## Aturan UI
1. Semua halaman harus responsive untuk ukuran mobile.
2. Gunakan SafeArea.
3. Gunakan SingleChildScrollView jika konten panjang.
4. Jangan membuat teks terlalu kecil.
5. Gunakan warna biru sebagai aksen utama.
6. Gunakan card putih agar tampilan bersih.
7. Hindari tampilan terlalu penuh.
8. Semua halaman harus punya navigasi kembali jika bukan halaman utama.
9. Gunakan loading state saat ambil data API.
10. Gunakan empty state jika data kosong.

## Contoh Empty State
Jika belum ada riwayat:
"Belum ada riwayat booking."

Jika dokter kosong:
"Data dokter belum tersedia."

Jika koneksi gagal:
"Gagal memuat data. Coba lagi."

## Catatan Desain
Desain harus mirip konsep Figma, tetapi boleh dirapikan agar lebih konsisten di Flutter. Prioritas utama adalah alur aplikasi jelas, mudah dipakai, dan tidak membingungkan user.