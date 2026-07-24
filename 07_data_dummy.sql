-- =====================================================================
-- 07. DATA UJI (DUMMY DATA)
-- Total 36 baris: dosen, mahasiswa, skripsi, bimbingan, sidang
-- =====================================================================

USE db_skripsi_mahasiswa;

INSERT INTO dosen (nip, nama, bidang_keahlian, email) VALUES
('D001', 'Dr. Andi Saputra', 'Basis Data', 'andi.saputra@kampus.ac.id'),
('D002', 'Dr. Siti Rahmawati', 'Jaringan Komputer', 'siti.rahmawati@kampus.ac.id'),
('D003', 'Dr. Budi Santoso', 'Kecerdasan Buatan', 'budi.santoso@kampus.ac.id'),
('D004', 'Dr. Rina Marlina', 'Rekayasa Perangkat Lunak', 'rina.marlina@kampus.ac.id'),
('D005', 'Dr. Hendra Wijaya', 'Sistem Informasi', 'hendra.wijaya@kampus.ac.id');

INSERT INTO mahasiswa (nim, nama, program_studi, angkatan, email, no_hp) VALUES
('IK2101001', 'Ahmad Fauzi', 'S1 Informatika', 2021, 'ahmad.fauzi@mhs.ac.id', '081234560001'),
('IK2101002', 'Nadia Putri', 'S1 Informatika', 2021, 'nadia.putri@mhs.ac.id', '081234560002'),
('IK2101003', 'Rizky Ramadhan', 'S1 Informatika', 2021, 'rizky.ramadhan@mhs.ac.id', '081234560003'),
('IK2102004', 'Dewi Lestari', 'S1 Informatika', 2021, 'dewi.lestari@mhs.ac.id', '081234560004'),
('IK2102005', 'Fajar Nugroho', 'S1 Informatika', 2021, 'fajar.nugroho@mhs.ac.id', '081234560005'),
('IK2102006', 'Putri Ayu', 'S1 Informatika', 2021, 'putri.ayu@mhs.ac.id', '081234560006'),
('IK2103007', 'Yusuf Hidayat', 'S1 Informatika', 2021, 'yusuf.hidayat@mhs.ac.id', '081234560007'),
('IK2103008', 'Melati Kusuma', 'S1 Informatika', 2021, 'melati.kusuma@mhs.ac.id', '081234560008');

-- pendaftaran skripsi menggunakan procedure (menunjukkan transaction control berjalan)
CALL sp_daftar_skripsi('IK2101001', 'D001', 'Sistem Rekomendasi Skripsi Berbasis Basis Data', '2025-08-01');
CALL sp_daftar_skripsi('IK2101002', 'D002', 'Analisis Keamanan Jaringan Kampus', '2025-08-05');
CALL sp_daftar_skripsi('IK2101003', 'D001', 'Implementasi Data Warehouse Akademik', '2025-08-10');
CALL sp_daftar_skripsi('IK2102004', 'D003', 'Klasifikasi Nilai Mahasiswa Menggunakan Machine Learning', '2025-08-12');
CALL sp_daftar_skripsi('IK2102005', 'D004', 'Sistem Informasi Manajemen Laboratorium', '2025-08-15');
CALL sp_daftar_skripsi('IK2102006', 'D005', 'Aplikasi Mobile Monitoring Skripsi', '2025-08-18');
CALL sp_daftar_skripsi('IK2103007', 'D002', 'Optimasi Query Basis Data Akademik', '2025-08-20');
CALL sp_daftar_skripsi('IK2103008', 'D003', 'Sistem Deteksi Plagiarisme Otomatis', '2025-08-22');

-- sesi bimbingan (beberapa skripsi diberi >=4 sesi agar bisa disidangkan)
CALL sp_tambah_bimbingan(1, '2025-08-15', 'Perbaikan bab I dan rumusan masalah', 'Revisi');
CALL sp_tambah_bimbingan(1, '2025-08-29', 'Perbaikan tinjauan pustaka', 'Revisi');
CALL sp_tambah_bimbingan(1, '2025-09-12', 'ERD dan struktur tabel disetujui', 'Selesai');
CALL sp_tambah_bimbingan(1, '2025-09-26', 'Progress implementasi 70%', 'Selesai');

CALL sp_tambah_bimbingan(2, '2025-08-20', 'Diskusi topik keamanan jaringan', 'Revisi');
CALL sp_tambah_bimbingan(2, '2025-09-03', 'Perbaikan metodologi', 'Revisi');
CALL sp_tambah_bimbingan(2, '2025-09-17', 'Hasil pengujian awal', 'Selesai');
CALL sp_tambah_bimbingan(2, '2025-10-01', 'Persiapan sidang', 'Selesai');

CALL sp_tambah_bimbingan(3, '2025-08-25', 'Perancangan skema data warehouse', 'Revisi');
CALL sp_tambah_bimbingan(3, '2025-09-08', 'Proses ETL disetujui', 'Selesai');

CALL sp_tambah_bimbingan(4, '2025-08-27', 'Studi literatur machine learning', 'Revisi');
CALL sp_tambah_bimbingan(4, '2025-09-10', 'Pemilihan algoritma klasifikasi', 'Revisi');
CALL sp_tambah_bimbingan(4, '2025-09-24', 'Evaluasi model', 'Selesai');
CALL sp_tambah_bimbingan(4, '2025-10-08', 'Perbaikan laporan akhir', 'Selesai');

-- menjadwalkan sidang untuk skripsi yang sudah memenuhi syarat (id 1, 2, dan 4)
CALL sp_jadwalkan_sidang(1, '2025-10-15');
CALL sp_jadwalkan_sidang(2, '2025-10-16');
CALL sp_jadwalkan_sidang(4, '2025-10-20');

-- input nilai sidang (memicu trigger validasi nilai, update status, dan audit log)
CALL sp_input_nilai_sidang(1, '2025-10-15', 85.50);
CALL sp_input_nilai_sidang(2, '2025-10-16', 65.00);
CALL sp_input_nilai_sidang(4, '2025-10-20', 78.25);

-- menjalankan pengecekan keterlambatan (cursor)
CALL sp_cek_keterlambatan_sidang();
