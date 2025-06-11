# Dompet Juara - Skema Database & Akses Data di Supabase 🏆💸

[![Database](https://img.shields.io/badge/Database-Supabase%20(PostgreSQL)-3979FF.svg)](https://supabase.com)
[![Akses Data](https://img.shields.io/badge/Akses%20Data-SQL%20%7C%20Client%20Libs%20%7C%20PostgREST-blue.svg)](#-cara-mengakses-database)
[![Otentikasi Dukungan](https://img.shields.io/badge/Otentikasi-Dukungan%20via%20Tabel-orange.svg)](#skema-database)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

"Dompet Juara" menyediakan skema database yang dirancang untuk aplikasi manajemen keuangan pribadi, diimplementasikan pada platform Supabase (PostgreSQL). Dokumen ini menjelaskan struktur database, cara melakukan setup, dan berbagai metode untuk mengakses data yang tersimpan.

## 📖 Daftar Isi

*   [✨ Fitur Utama Database](#-fitur-utama-database)
*   [📝 Gambaran Umum Skema](#-gambaran-umum-skema)
*   [🛠️ Teknologi Database](#️-teknologi-database)
*   [🗄️ Detail Skema Database](#️-detail-skema-database)
*   [📂 Struktur Proyek (untuk Migrasi DB)](#-struktur-proyek-untuk-migrasi-db)
*   [⚙️ Pengaturan Database di Supabase](#️-pengaturan-database-di-supabase)
    *   [Prasyarat](#prasyarat)
    *   [Membuat Proyek Supabase](#membuat-proyek-supabase)
    *   [Menjalankan Skema SQL](#menjalankan-skema-sql)
    *   [Konfigurasi Supabase Storage (Opsional)](#konfigurasi-supabase-storage-opsional)
*   [🚀 Cara Mengakses Database](#-cara-mengakses-database)
    *   [Kredensial Akses Database](#kredensial-akses-database)
    *   [1. Supabase SQL Editor](#1-supabase-sql-editor)
    *   [2. Klien SQL Eksternal (cth: DBeaver, pgAdmin)](#2-klien-sql-eksternal-cth-dbeaver-pgadmin)
    *   [3. Supabase Client Libraries (cth: `supabase-js`)](#3-supabase-client-libraries-cth-supabase-js)
    *   [4. PostgREST API (Otomatis oleh Supabase)](#4-postgrest-api-otomatis-oleh-supabase)
*   [🛡️ Keamanan Data (RLS)](#️-keamanan-data-rls)
*   [🤝 Berkontribusi pada Skema](#-berkontribusi-pada-skema)
*   [📜 Lisensi](#-lisensi)
*   [🙏 Ucapan Terima Kasih](#-ucapan-terima-kasih)
*   [📧 Kontak / Penulis](#-kontak--penulis)

## ✨ Fitur Utama Database

*   **Penyimpanan Data Pengguna**: Menyimpan informasi profil pengguna termasuk `avatar_url`.
*   **Dukungan Sesi Pengguna**: Tabel `refresh_tokens` untuk mendukung mekanisme otentikasi.
*   **Pencatatan Pemasukan Terstruktur**: Menyimpan data pemasukan dengan kategori yang telah ditentukan.
*   **Pencatatan Pengeluaran Terstruktur**: Menyimpan data pengeluaran dengan kategori detail, selaras dengan kebutuhan analisis.
*   **Kategori Transaksi Standar**: Tabel master untuk kategori pemasukan dan pengeluaran guna menjaga konsistensi data.
*   **Relasi Data yang Jelas**: Integritas data antar tabel dijaga melalui Foreign Keys.
*   **Indeks untuk Performa**: Indeks pada kolom yang sering di-query untuk optimasi.

## 📝 Gambaran Umum Skema

Skema database ini adalah fondasi data untuk aplikasi "Dompet Juara". Tujuannya adalah untuk:
1.  Menyimpan detail pengguna dan kredensial pendukung otentikasi.
2.  Mencatat semua transaksi keuangan (pemasukan dan pengeluaran) secara terperinci.
3.  Menyediakan daftar kategori standar untuk transaksi, di mana kategori pengeluaran disesuaikan untuk potensi integrasi dengan model Machine Learning.
4.  Mendukung penyimpanan aset seperti avatar pengguna melalui Supabase Storage.

Fokus utama adalah pada struktur data yang baik, kemudahan akses, dan keandalan data.

## 🛠️ Teknologi Database

*   **Platform**: Supabase
*   **Database Inti**: PostgreSQL
*   **Bahasa Definisi Skema**: SQL
*   **Akses API Otomatis**: PostgREST (disediakan oleh Supabase)

## 🗄️ Detail Skema Database

Database "Dompet Juara" terdiri dari tabel-tabel berikut:

*   **`users`**: Menyimpan informasi akun pengguna.
    *   Kolom Kunci: `id` (SERIAL, internal FK), `uuid` (UUID, publik PK), `username` (UNIQUE), `email` (UNIQUE), `password` (hashed), `name`, `avatar_url`.
*   **`refresh_tokens`**: Menyimpan refresh token untuk mendukung manajemen sesi.
    *   Kolom Kunci: `user_id` (FK ke `users.id`), `token` (UNIQUE), `expires_at`.
*   **`kategori_pemasukan`**: Tabel master kategori pemasukan.
    *   Kolom Kunci: `id` (PK), `nama` (UNIQUE).
    *   Data Awal: 'Gaji', 'Tabungan Lama', 'Investasi', 'Pemasukan Lainnya'.
*   **`pemasukan`**: Mencatat transaksi pemasukan pengguna.
    *   Kolom Kunci: `id` (PK), `user_id` (FK ke `users.id`), `jumlah`, `tanggal`, `kategori_id` (FK ke `kategori_pemasukan.id`).
*   **`kategori_pengeluaran`**: Tabel master kategori pengeluaran.
    *   Kolom Kunci: `id` (PK), `nama` (UNIQUE).
    *   Data Awal: 'Bahan Pokok', 'Protein Gizi', 'Tempat Tinggal', 'Sandang', 'Konsumsi Praktis', 'Barang Jasa Sekunder', 'Pengeluaran Tidak Esensial', 'Pajak', 'Asuransi', 'Sosial Budaya', 'Tabungan Investasi'.
*   **`pengeluaran`**: Mencatat transaksi pengeluaran pengguna.
    *   Kolom Kunci: `id` (PK), `user_id` (FK ke `users.id`), `kategori_id` (FK ke `kategori_pengeluaran.id`), `jumlah`, `tanggal`.

**Indeks**: Dibuat pada `refresh_tokens(user_id, is_revoked)`, `pemasukan(user_id, tanggal)`, `pengeluaran(user_id, tanggal)`.
**Kebijakan RLS (Row Level Security)**: Sangat penting untuk dikonfigurasi. Lihat bagian [Keamanan Data](#️-keamanan-data-rls).

## 📂 Struktur Proyek (untuk Migrasi DB)

Jika menggunakan Supabase CLI untuk manajemen migrasi database, struktur direktori Anda mungkin terlihat seperti ini:

```
dompet-juara-db/
├── supabase/
│   ├── migrations/
│   │   └── YYYYMMDDHHMMSS_initial_schema.sql  # File SQL skema database ini
│   ├── config.toml                            # Konfigurasi Supabase CLI
│   └── seed.sql                               # (Opsional) Data awal untuk tabel kategori
├── .env                                       # (Untuk client library) Simpan kredensial Supabase
├── .gitignore
└── README.md                                  # File ini
```
File `.env` akan digunakan jika Anda mengakses database melalui client library (lihat contoh `supabase.js`).

## ⚙️ Pengaturan Database di Supabase

### Prasyarat

*   Akun Supabase ([supabase.com](https://supabase.com)).
*   (Opsional) Supabase CLI terinstal jika ingin mengelola migrasi dari lokal.
*   (Opsional) Klien SQL seperti DBeaver, pgAdmin jika ingin akses GUI langsung.
*   (Opsional) Node.js dan npm/yarn jika ingin menggunakan `supabase-js`.

### Membuat Proyek Supabase

1.  Masuk ke [dashboard Supabase](https://app.supabase.io) dan buat proyek baru.
2.  Setelah proyek dibuat, catat **URL Proyek** dan **Kunci API** (khususnya `anon public` key dan `service_role` key). Anda akan menemukannya di `Project Settings` > `API`.

### Menjalankan Skema SQL

Anda dapat menerapkan skema SQL yang disediakan (lihat file `initial_schema.sql` atau kode di awal prompt) dengan cara berikut:

1.  **Melalui Supabase SQL Editor (Cara Mudah)**:
    *   Di dashboard Supabase proyek Anda, navigasi ke "SQL Editor".
    *   Klik "+ New query".
    *   Salin seluruh skrip SQL (mulai dari `CREATE TABLE users` hingga `CREATE INDEX ...`) dan tempelkan ke editor.
    *   Klik "RUN". Periksa output untuk memastikan tidak ada error. Bagian `INSERT INTO kategori...` juga disertakan untuk data awal.

2.  **Menggunakan Supabase CLI (Untuk Pengembangan Berkelanjutan)**:
    *   Inisialisasi Supabase di direktori proyek Anda: `supabase init`
    *   Hubungkan ke proyek remote Anda: `supabase login` lalu `supabase link --project-ref <PROJECT_ID_ANDA>`
    *   Buat file migrasi baru (misalnya, untuk skema awal): `supabase migration new initial_schema`
    *   Salin skrip SQL ke dalam file migrasi yang baru dibuat (misalnya `supabase/migrations/<timestamp>_initial_schema.sql`).
    *   Terapkan migrasi ke database Supabase remote: `supabase db push` (jika menggunakan Supabase Studio lokal `supabase start` dulu) atau `supabase migration up` (untuk skema yang lebih terkontrol).

### Konfigurasi Supabase Storage (Opsional)

Jika Anda ingin menggunakan fitur `avatar_url` pada tabel `users`:

1.  **Buat Bucket**:
    *   Di dashboard Supabase, navigasi ke "Storage".
    *   Klik "New bucket", beri nama (misalnya, `profile-pictures`). Anda bisa menjadikannya publik atau privat dengan kebijakan.
2.  **Atur Kebijakan RLS untuk Bucket**: Ini krusial untuk keamanan.
    *   Contoh: Izinkan pengguna terotentikasi mengunggah ke folder mereka sendiri dan izinkan baca publik.
    ```sql
    -- Kebijakan untuk INSERT (Upload) oleh pemilik
    CREATE POLICY "Allow authenticated uploads to own folder"
    ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'profile-pictures' AND (storage.foldername(name))[1] = auth.uid()::text);

    -- Kebijakan untuk SELECT (Read) publik
    CREATE POLICY "Allow public read access"
    ON storage.objects FOR SELECT TO anon, authenticated
    USING (bucket_id = 'profile-pictures');
    ```
    Terapkan kebijakan ini melalui SQL Editor atau sebagai bagian dari migrasi.

## 🚀 Cara Mengakses Database

Setelah skema diterapkan, Anda dapat mengakses data di database Supabase Anda melalui beberapa cara:

### Kredensial Akses Database

Anda akan memerlukan informasi berikut dari dashboard Supabase (`Project Settings` > `Database` > `Connection info` untuk klien SQL, dan `Project Settings` > `API` untuk client libraries/PostgREST):

*   **Host**: `db.<PROJECT_ID_ANDA>.supabase.co`
*   **Database**: `postgres`
*   **Port**: `5432`
*   **User**: `postgres`
*   **Password**: [Password yang Anda set saat membuat proyek]
*   **URL Proyek Supabase**: `https://<PROJECT_ID_ANDA>.supabase.co`
*   **Kunci API `anon` (public)**: Untuk akses dari sisi klien (misalnya, frontend, mobile) dengan RLS.
*   **Kunci API `service_role` (secret)**: Untuk akses dengan hak admin penuh (bypass RLS), **gunakan hanya di lingkungan server yang aman**.

### 1. Supabase SQL Editor

*   Langsung dari dashboard Supabase Anda.
*   Navigasi ke "SQL Editor".
*   Tulis dan jalankan query SQL standar (SELECT, INSERT, UPDATE, DELETE) sesuai hak akses Anda.

### 2. Klien SQL Eksternal (cth: DBeaver, pgAdmin)

*   Gunakan kredensial koneksi database (Host, Port, DB, User, Password) untuk terhubung.
*   Ini memungkinkan Anda menjalankan query SQL, menjelajahi skema, dan mengelola database dengan antarmuka grafis.

### 3. Supabase Client Libraries (cth: `supabase-js`)

Supabase menyediakan pustaka klien untuk berbagai bahasa. Contoh untuk JavaScript (`supabase-js`):

**a. Setup Awal (di proyek Node.js Anda):**
   Install `supabase-js` dan `dotenv`:
   ```bash
   npm install @supabase/supabase-js dotenv
   ```
   Buat file `.env` di root proyek:
   ```
   SUPABASE_URL=https://<ID_PROYEK_ANDA>.supabase.co
   SUPABASE_KEY=<KUNCI_ANON_PUBLIK_ANDA_ATAU_SERVICE_ROLE_KEY_JIKA_DI_BACKEND>
   ```
   Buat file `supabaseClient.js` (atau nama serupa):
   ```javascript
   // supabaseClient.js
   require('dotenv').config();
   const { createClient } = require('@supabase/supabase-js');

   const supabaseUrl = process.env.SUPABASE_URL;
   const supabaseKey = process.env.SUPABASE_KEY;

   if (!supabaseUrl || !supabaseKey) {
     console.error("Kesalahan: SUPABASE_URL atau SUPABASE_KEY tidak ditemukan di .env.");
     throw new Error("Konfigurasi Supabase tidak lengkap.");
   }

   const supabase = createClient(supabaseUrl, supabaseKey);
   module.exports = supabase;
   ```

**b. Contoh Penggunaan:**
   ```javascript
   // contohPenggunaan.js
   const supabase = require('./supabaseClient');

   async function getAllUsers() {
     const { data, error } = await supabase
       .from('users')
       .select('*');

     if (error) {
       console.error("Error mengambil data users:", error);
       return;
     }
     console.log("Data Users:", data);
   }

   async function getExpensesForUser(userId) {
     const { data, error } = await supabase
       .from('pengeluaran')
       .select(`
         jumlah,
         keterangan,
         tanggal,
         kategori_pengeluaran (nama)
       `)
       .eq('user_id', userId); // Pastikan user_id adalah ID internal (integer) dari tabel users

     if (error) {
       console.error(`Error mengambil pengeluaran untuk user ${userId}:`, error);
       return;
     }
     console.log(`Pengeluaran untuk User ${userId}:`, data);
   }

   // Panggil fungsi (misalnya)
   // getAllUsers();
   // getExpensesForUser(1); // Ganti 1 dengan ID user yang valid
   ```
   **Catatan**: Jika menggunakan `anon` key, pastikan kebijakan RLS memperbolehkan operasi yang Anda lakukan.

### 4. PostgREST API (Otomatis oleh Supabase)

Supabase secara otomatis membuat API RESTful untuk tabel database Anda menggunakan PostgREST.

*   **URL dasar**: `https://<PROJECT_ID_ANDA>.supabase.co/rest/v1/<NAMA_TABEL>`
*   **Otentikasi**: Gunakan `apikey` header dengan kunci `anon` atau `service_role`.
*   **Contoh (menggunakan `curl` atau Postman):**
    ```bash
    # Mengambil semua data dari tabel 'users' (memerlukan service_role atau RLS yang memperbolehkan)
    curl -X GET \
      -H "apikey: <KUNCI_ANON_ATAU_SERVICE_ROLE_ANDA>" \
      "https://<PROJECT_ID_ANDA>.supabase.co/rest/v1/users"

    # Mengambil data dari tabel 'pengeluaran' untuk user_id tertentu
    # (Asumsikan RLS memperbolehkan untuk anon key jika user_id sesuai dengan auth.uid(), atau gunakan service_role)
    curl -X GET \
      -H "apikey: <KUNCI_ANON_ATAU_SERVICE_ROLE_ANDA>" \
      "https://<PROJECT_ID_ANDA>.supabase.co/rest/v1/pengeluaran?user_id=eq.1&select=*"
    ```
    Dokumentasi API untuk setiap tabel juga tersedia di dashboard Supabase Anda (`API Docs`).

## 🛡️ Keamanan Data (RLS)

**Row Level Security (RLS) adalah fitur keamanan krusial di PostgreSQL dan Supabase.**

*   **Secara default, Supabase mengaktifkan RLS untuk tabel baru.** Ini berarti tidak ada data yang bisa diakses kecuali ada kebijakan (policy) yang secara eksplisit mengizinkannya.
*   **Anda WAJIB membuat kebijakan RLS** untuk setiap tabel untuk mengontrol siapa yang bisa mengakses (SELECT) atau memodifikasi (INSERT, UPDATE, DELETE) baris data tertentu.
*   Contoh kebijakan RLS:
    ```sql
    -- Izinkan pengguna membaca data mereka sendiri di tabel 'pemasukan'
    CREATE POLICY "Allow individual read access on pemasukan"
    ON pemasukan FOR SELECT
    TO authenticated
    USING (auth.uid() = (SELECT uuid FROM users WHERE id = user_id)); -- Cocokkan uuid pengguna terotentikasi dengan uuid di tabel users yang berelasi

    -- Izinkan pengguna memasukkan data mereka sendiri di tabel 'pemasukan'
    CREATE POLICY "Allow individual insert access on pemasukan"
    ON pemasukan FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = (SELECT uuid FROM users WHERE id = user_id));
    ```
*   Terapkan kebijakan RLS melalui SQL Editor. **Jangan mengandalkan `service_role` key untuk semua operasi dari aplikasi Anda; gunakan `anon` key dengan RLS yang ketat.**

## 🤝 Berkontribusi pada Skema

Kontribusi untuk perbaikan atau pengembangan skema database ini dipersilakan.

1.  **Fork repositori** (jika ini dikelola dalam repositori Git).
2.  Buat **branch baru** untuk perubahan Anda.
3.  Lakukan perubahan pada file skema SQL. Jika menggunakan Supabase CLI, buat file migrasi baru.
4.  Commit dan **push perubahan** Anda.
5.  Buka **Pull Request** dengan deskripsi yang jelas.
    Diskusikan perubahan signifikan melalui *Issues* terlebih dahulu.

## 📜 Lisensi

Proyek ini dilisensikan di bawah [**Lisensi MIT**](LICENSE) (asumsikan ada file LICENSE).

## 🙏 Ucapan Terima Kasih

*   Tim [Supabase](https://supabase.com) untuk platformnya yang luar biasa.
*   Komunitas [PostgreSQL](https://www.postgresql.org) untuk databasenya yang tangguh.

## 📧 Kontak / Penulis

*   **Tim Proyek**: Dompet Juara
*   **Organisasi GitHub**: [https://github.com/dompet-juara](https://github.com/dompet-juara)
*   **Email**: juaradompet@gmail.com
