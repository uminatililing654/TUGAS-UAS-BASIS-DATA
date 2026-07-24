-- =====================================================================
-- 08. CONTOH QUERY PENGUJIAN (BAB IV)
-- Uncomment baris yang ingin dijalankan untuk menguji objek tertentu
-- =====================================================================

USE db_skripsi_mahasiswa;

-- Uji fungsi
-- SELECT fn_hitung_jumlah_bimbingan(3);
-- SELECT fn_status_kelulusan(72.00);
-- SELECT fn_durasi_penyelesaian(1);

-- Uji exception handling: dosen D001 sudah membimbing 2 mahasiswa aktif,
-- jalankan berkali-kali (>=5x) untuk memicu SIGNAL kuota terlampaui:
-- CALL sp_daftar_skripsi('IK2103008', 'D001', 'Judul uji kuota', '2025-11-01');

-- Uji exception handling: coba jadwalkan sidang untuk skripsi id_skripsi = 3
-- yang baru punya 2 sesi bimbingan (< 4), akan memicu SIGNAL:
-- CALL sp_jadwalkan_sidang(3, '2025-10-25');

-- Uji trigger validasi nilai: nilai di luar 0-100 akan ditolak
-- CALL sp_input_nilai_sidang(3, '2025-10-25', 150);

-- Uji audit log
-- SELECT * FROM audit_log ORDER BY waktu DESC;

-- Uji hasil integrasi
-- SELECT s.id_skripsi, m.nama, d.nama AS pembimbing, s.judul, s.status,
--        fn_hitung_jumlah_bimbingan(s.id_skripsi) AS total_bimbingan
-- FROM skripsi s
-- JOIN mahasiswa m ON s.nim = m.nim
-- JOIN dosen d ON s.nip_pembimbing = d.nip;

-- Uji perbandingan performa index (jalankan EXPLAIN sebelum & sesudah index dibuat)
-- EXPLAIN SELECT * FROM mahasiswa WHERE nama = 'Ahmad Fauzi';
-- EXPLAIN SELECT * FROM sidang WHERE tanggal_sidang = '2025-10-15';
