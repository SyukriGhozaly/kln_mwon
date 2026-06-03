# AGENTS.md

## Nama Project
Klinik Mawon - Mobile Booking Klinik Online

## Deskripsi Singkat
Aplikasi mobile Flutter untuk sistem booking klinik online. User dapat daftar/login, melihat daftar dokter/poli, memilih jadwal dokter, melakukan booking, memilih metode pembayaran, melihat kode antrian/QR, melihat riwayat kunjungan, dan mengelola profil.

## Tujuan Pengembangan
Bangun aplikasi Flutter berdasarkan desain Figma yang sudah ada dengan tampilan modern, rapi, dan konsisten. Fokus utama adalah alur aplikasi berjalan dulu, tampilan mengikuti DESIGN.md.

## Tech Stack
- Flutter
- Dart
- Material Design
- HTTP/API integration ke backend CodeIgniter 4
- State management sederhana dulu, boleh pakai Provider / Bloc jika sudah ada struktur sebelumnya
- Local storage untuk token login, misalnya SharedPreferences

## Aturan Kerja Codex
1. Jangan membuat project Flutter baru.
2. Kerjakan di struktur project Flutter yang sudah ada.
3. Jangan menghapus file penting tanpa alasan.
4. Jangan mengubah nama package sembarangan.
5. Jika ada error, perbaiki langsung sampai aplikasi bisa run.
6. Prioritaskan alur login, register, home, booking, pembayaran, tiket/antrian, riwayat, dan profil.
7. Gunakan desain dari DESIGN.md sebagai acuan UI.
8. Buat kode yang rapi, mudah dibaca, dan dipisah per fitur.
9. Jangan hardcode data terus-menerus jika sudah ada API.
10. Jika API belum siap, gunakan dummy data sementara dengan struktur yang mudah diganti ke API.

## Role Aplikasi

### Guest
Guest hanya boleh:
- Melihat halaman onboarding/splash
- Login
- Register

Guest tidak boleh:
- Booking dokter
- Melihat jadwal
- Masuk home utama
- Melihat profil
- Melihat riwayat

Jika belum login dan mencoba masuk fitur utama, arahkan ke login.

### User / Pasien
User dapat:
- Login dan register
- Melihat home
- Melihat daftar poli/dokter
- Melihat detail dokter
- Memilih jadwal dokter
- Membuat booking
- Melihat detail booking
- Melakukan pembayaran
- Melihat kode antrian / QR
- Melihat riwayat kunjungan
- Mengedit profil
- Logout

### Admin
Untuk aplikasi mobile ini admin tidak wajib dibuat penuh.
Jika diperlukan, cukup siapkan struktur role dari API.
Admin utama tetap di web backend.

## Alur Utama Aplikasi

### 1. Splash / Opening
- Tampilkan logo Klinik Mawon
- Setelah beberapa detik cek token login
- Jika ada token masuk ke Home
- Jika tidak ada token masuk ke Login

### 2. Login
Input:
- Email / username
- Password

Aksi:
- Tombol Sign In
- Link Register
- Login Google/Facebook boleh dibuat dummy tampilan dulu

Validasi:
- Email tidak boleh kosong
- Password tidak boleh kosong
- Jika berhasil, simpan token dan data user

### 3. Register
Input:
- Nama lengkap
- Email
- No HP
- Password
- Konfirmasi password

Aksi:
- Tombol Daftar
- Link Login

Validasi:
- Semua field wajib
- Password dan konfirmasi harus sama

### 4. Home
Isi:
- Header sapaan user
- Banner promo / informasi klinik
- Menu cepat:
  - Daftar Dokter
  - Jadwal Dokter
  - Booking
  - Riwayat
- Card dokter/poli populer
- Bottom navigation

### 5. Daftar Dokter / Poli
Isi:
- List dokter berdasarkan poli
- Foto dokter
- Nama dokter
- Spesialis
- Jam praktik
- Tombol lihat detail / booking

### 6. Detail Jadwal
Isi:
- Data dokter
- Jadwal praktik
- Pilihan tanggal
- Pilihan jam
- Tombol lanjut booking

### 7. Booking
Isi:
- Nama pasien
- Dokter
- Poli
- Tanggal
- Jam
- Keluhan
- Metode pembayaran

Setelah submit:
- Status booking menjadi menunggu pembayaran / menunggu konfirmasi

### 8. Pembayaran
Isi:
- Total biaya
- Metode pembayaran
- QRIS / transfer / bayar di tempat
- Tombol konfirmasi pembayaran

### 9. Tiket / Kode Antrian
Isi:
- Kode booking
- Nomor antrian
- QR Code
- Nama pasien
- Dokter
- Jadwal
- Status

### 10. Riwayat
Isi:
- List booking sebelumnya
- Status:
  - Menunggu pembayaran
  - Menunggu konfirmasi
  - Terjadwal
  - Selesai
  - Dibatalkan

### 11. Profil
Isi:
- Foto user
- Nama
- Email
- No HP
- Menu:
  - Edit Profil
  - Riwayat
  - Bantuan
  - Tentang Aplikasi
  - Logout

## Struktur Folder yang Disarankan

lib/
- main.dart
- app.dart
- core/
  - constants/
  - theme/
  - utils/
  - widgets/
  - services/
- features/
  - auth/
    - screens/
    - widgets/
    - services/
    - models/
  - home/
    - screens/
    - widgets/
  - doctor/
    - screens/
    - widgets/
    - models/
    - services/
  - booking/
    - screens/
    - widgets/
    - models/
    - services/
  - payment/
    - screens/
    - widgets/
  - history/
    - screens/
    - widgets/
  - profile/
    - screens/
    - widgets/

## Endpoint API yang Disiapkan
Sesuaikan dengan backend CI4.

Contoh:
- POST /api/login
- POST /api/register
- POST /api/logout
- GET /api/profile
- PUT /api/profile
- GET /api/doctors
- GET /api/doctors/{id}
- GET /api/schedules
- POST /api/bookings
- GET /api/bookings
- GET /api/bookings/{id}
- POST /api/payments
- POST /api/bookings/{id}/cancel

## Catatan Penting
- Jangan terlalu fokus animasi dulu.
- Pastikan semua halaman bisa berpindah dengan lancar.
- Gunakan dummy data jika API belum siap.
- Setelah UI selesai, baru sambungkan ke API.
- Semua tombol utama harus aktif walaupun sementara mengarah ke halaman dummy.