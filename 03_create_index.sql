-- =====================================================================
-- 03. INDEXING
-- Kolom yang sering dipakai untuk pencarian/filter
-- =====================================================================

USE db_skripsi_mahasiswa;

-- idx_nama_mahasiswa: pencarian mahasiswa berdasarkan nama sering dilakukan
--                      oleh admin/petugas akademik saat rekap data
CREATE INDEX idx_nama_mahasiswa ON mahasiswa(nama);

-- idx_tanggal_sidang: laporan/rekap sidang per periode difilter berdasarkan tanggal
CREATE INDEX idx_tanggal_sidang ON sidang(tanggal_sidang);

-- idx_status_skripsi: dashboard progres skripsi sering memfilter berdasarkan status
CREATE INDEX idx_status_skripsi ON skripsi(status);
