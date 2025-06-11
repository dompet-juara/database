-- Hapus tabel jika sudah ada sebelumnya (opsional, untuk setup yang bersih)
-- DROP TABLE IF EXISTS pengeluaran CASCADE;
-- DROP TABLE IF EXISTS kategori_pengeluaran CASCADE;
-- DROP TABLE IF EXISTS pemasukan CASCADE;
-- DROP TABLE IF EXISTS kategori_pemasukan CASCADE;
-- DROP TABLE IF EXISTS refresh_tokens CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- Tabel pengguna
CREATE TABLE users (
  id SERIAL UNIQUE,                                 -- ID internal, digunakan sebagai foreign key
  uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- UUID publik
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  avatar_url TEXT,                                  -- URL foto profil
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabel refresh token
CREATE TABLE refresh_tokens (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  ip_address INET,                                   -- Alamat IP saat login
  user_agent TEXT,                                   -- Informasi perangkat
  is_revoked BOOLEAN DEFAULT FALSE,                  -- Apakah token sudah tidak berlaku
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL                      -- Waktu kedaluwarsa token
);

-- Tabel kategori pemasukan (selaras dengan fitur AI)
CREATE TABLE kategori_pemasukan (
  id SERIAL PRIMARY KEY,
  nama TEXT UNIQUE NOT NULL                          -- Contoh: "Gaji", "Tabungan Lama", "Investasi", "Pemasukan Lainnya"
);

-- Isi data awal kategori pemasukan
INSERT INTO kategori_pemasukan (nama) VALUES
  ('Gaji'),
  ('Tabungan Lama'),
  ('Investasi'),
  ('Pemasukan Lainnya')
ON CONFLICT (nama) DO NOTHING;

-- Tabel pemasukan
CREATE TABLE pemasukan (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  jumlah NUMERIC NOT NULL,
  keterangan TEXT,                                    -- Catatan tambahan
  tanggal TIMESTAMP DEFAULT NOW(),
  kategori_id INTEGER REFERENCES kategori_pemasukan(id) ON DELETE SET NULL
);

-- Tabel kategori pengeluaran (selaras dengan fitur AI)
CREATE TABLE kategori_pengeluaran (
  id SERIAL PRIMARY KEY,
  nama TEXT UNIQUE NOT NULL                          -- Contoh: "Bahan Pokok", "Pajak", dll.
);

-- Isi data awal kategori pengeluaran
INSERT INTO kategori_pengeluaran (nama) VALUES
  ('Bahan Pokok'),
  ('Protein Gizi'),
  ('Tempat Tinggal'),
  ('Sandang'),
  ('Konsumsi Praktis'),
  ('Barang Jasa Sekunder'),
  ('Pengeluaran Tidak Esensial'),
  ('Pajak'),
  ('Asuransi'),
  ('Sosial Budaya'),
  ('Tabungan Investasi')
ON CONFLICT (nama) DO NOTHING;

-- Tabel pengeluaran
CREATE TABLE pengeluaran (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kategori_id INTEGER REFERENCES kategori_pengeluaran(id) ON DELETE SET NULL,
  jumlah NUMERIC NOT NULL,
  keterangan TEXT,
  tanggal TIMESTAMP DEFAULT NOW()
);

-- Index untuk mempercepat query
CREATE INDEX ON refresh_tokens(user_id, is_revoked);
CREATE INDEX ON pemasukan(user_id, tanggal);
CREATE INDEX ON pengeluaran(user_id, tanggal);

-- Catatan:
-- Pastikan bucket 'profile-pictures' telah dibuat di Supabase Storage
-- dan kebijakan RLS (Row-Level Security) telah disesuaikan.

-- Contoh kebijakan RLS untuk bucket 'profile-pictures':

-- 1. Izinkan pengguna yang telah login mengunggah ke folder mereka sendiri:
--    - Role target: authenticated
--    - Operasi yang diizinkan: INSERT
--    - Ekspresi USING: (bucket_id = 'profile-pictures') AND ((storage.foldername(name))[1] = (auth.uid())::text)
--    - Ekspresi WITH CHECK: (bucket_id = 'profile-pictures') AND ((storage.foldername(name))[1] = (auth.uid())::text)

-- 2. Izinkan akses baca publik (jika diinginkan):
--    - Role target: anon, authenticated
--    - Operasi yang diizinkan: SELECT
--    - Ekspresi USING: (bucket_id = 'profile-pictures')

-- 3. Jika hanya pemilik yang boleh membaca:
--    - Role target: authenticated
--    - Operasi yang diizinkan: SELECT
--    - Ekspresi USING: (bucket_id = 'profile-pictures') AND ((storage.foldername(name))[1] = (auth.uid())::text)

-- 4. Untuk operasi UPDATE (misalnya saat menggunakan upsert: true):
--    - Role target: authenticated
--    - Operasi yang diizinkan: UPDATE
--    - Ekspresi USING dan WITH CHECK sama seperti INSERT di atas.
