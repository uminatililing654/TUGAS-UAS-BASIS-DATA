-- =====================================================================
-- 04. FUNCTION
-- 3 function: fn_hitung_jumlah_bimbingan, fn_status_kelulusan, fn_durasi_penyelesaian
-- =====================================================================

USE db_skripsi_mahasiswa;

DELIMITER $$

-- Function 1: menghitung jumlah sesi bimbingan yang sudah dilakukan
CREATE FUNCTION fn_hitung_jumlah_bimbingan(p_id_skripsi INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_jumlah INT;
    SELECT COUNT(*) INTO v_jumlah
    FROM bimbingan
    WHERE id_skripsi = p_id_skripsi;
    RETURN v_jumlah;
END$$

-- Function 2: menentukan status kelulusan berdasarkan nilai sidang
CREATE FUNCTION fn_status_kelulusan(p_nilai DECIMAL(5,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_status VARCHAR(20);
    IF p_nilai >= 70 THEN
        SET v_status = 'Lulus';
    ELSE
        SET v_status = 'Tidak Lulus';
    END IF;
    RETURN v_status;
END$$

-- Function 3: menghitung lama pengerjaan skripsi (hari) dari pengajuan sampai sidang
CREATE FUNCTION fn_durasi_penyelesaian(p_id_skripsi INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_tgl_ajuan DATE;
    DECLARE v_tgl_sidang DATE;
    DECLARE v_durasi INT;

    SELECT tanggal_pengajuan INTO v_tgl_ajuan
    FROM skripsi WHERE id_skripsi = p_id_skripsi;

    SELECT MAX(tanggal_sidang) INTO v_tgl_sidang
    FROM sidang WHERE id_skripsi = p_id_skripsi;

    IF v_tgl_sidang IS NULL THEN
        RETURN NULL;
    END IF;

    SET v_durasi = DATEDIFF(v_tgl_sidang, v_tgl_ajuan);
    RETURN v_durasi;
END$$

DELIMITER ;
