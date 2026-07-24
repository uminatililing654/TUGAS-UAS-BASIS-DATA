-- =====================================================================
-- 06. STORED PROCEDURE
-- 5 procedure: sp_daftar_skripsi, sp_tambah_bimbingan, sp_jadwalkan_sidang,
--              sp_input_nilai_sidang, sp_cek_keterlambatan_sidang (cursor)
-- Termasuk Transaction Control & Exception Handling
-- =====================================================================

USE db_skripsi_mahasiswa;

DELIMITER $$

-- Procedure 1: pendaftaran skripsi baru
-- Exception Handling skenario 1: kuota bimbingan dosen maksimal 5 mahasiswa aktif
-- Transaction Control: START TRANSACTION, SAVEPOINT, COMMIT, ROLLBACK
CREATE PROCEDURE sp_daftar_skripsi(
    IN p_nim VARCHAR(15),
    IN p_nip_pembimbing VARCHAR(20),
    IN p_judul VARCHAR(255),
    IN p_tanggal_pengajuan DATE
)
BEGIN
    DECLARE v_jumlah_bimbingan_aktif INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK TO SAVEPOINT sp_sebelum_daftar;
        RESIGNAL;
    END;

    START TRANSACTION;
    SAVEPOINT sp_sebelum_daftar;

    SELECT COUNT(*) INTO v_jumlah_bimbingan_aktif
    FROM skripsi
    WHERE nip_pembimbing = p_nip_pembimbing
      AND status NOT IN ('Lulus', 'Tidak Lulus');

    IF v_jumlah_bimbingan_aktif >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dosen pembimbing sudah mencapai kuota maksimal 5 mahasiswa aktif';
    END IF;

    INSERT INTO skripsi(nim, nip_pembimbing, judul, tanggal_pengajuan, status)
    VALUES (p_nim, p_nip_pembimbing, p_judul, p_tanggal_pengajuan, 'Diajukan');

    COMMIT;
END$$

-- Procedure 2: mencatat sesi bimbingan, otomatis mengubah status skripsi
CREATE PROCEDURE sp_tambah_bimbingan(
    IN p_id_skripsi INT,
    IN p_tanggal DATE,
    IN p_catatan TEXT,
    IN p_progres VARCHAR(10)
)
BEGIN
    INSERT INTO bimbingan(id_skripsi, tanggal_bimbingan, catatan, progres)
    VALUES (p_id_skripsi, p_tanggal, p_catatan, p_progres);

    UPDATE skripsi
    SET status = 'Bimbingan'
    WHERE id_skripsi = p_id_skripsi AND status = 'Diajukan';
END$$

-- Procedure 3: menjadwalkan sidang
-- Exception Handling skenario 2: minimal 4 sesi bimbingan sebelum boleh sidang
CREATE PROCEDURE sp_jadwalkan_sidang(
    IN p_id_skripsi INT,
    IN p_tanggal_sidang DATE
)
BEGIN
    DECLARE v_jumlah_bimbingan INT;

    SET v_jumlah_bimbingan = fn_hitung_jumlah_bimbingan(p_id_skripsi);

    IF v_jumlah_bimbingan < 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Belum memenuhi syarat sidang: minimal 4 sesi bimbingan diperlukan';
    END IF;

    UPDATE skripsi
    SET status = 'Siap Sidang'
    WHERE id_skripsi = p_id_skripsi;

    -- catatan: nilai sidang diinput terpisah lewat sp_input_nilai_sidang
    -- baris ini hanya menandai jadwal sidang sudah ditentukan
    INSERT INTO audit_log(nama_tabel, aksi, id_terkait, keterangan)
    VALUES ('skripsi', 'JADWAL_SIDANG', p_id_skripsi,
            CONCAT('Sidang dijadwalkan tanggal ', p_tanggal_sidang));
END$$

-- Procedure 4: input nilai sidang (memicu trigger validasi & update status)
CREATE PROCEDURE sp_input_nilai_sidang(
    IN p_id_skripsi INT,
    IN p_tanggal_sidang DATE,
    IN p_nilai DECIMAL(5,2)
)
BEGIN
    INSERT INTO sidang(id_skripsi, tanggal_sidang, nilai)
    VALUES (p_id_skripsi, p_tanggal_sidang, p_nilai);
END$$

-- Procedure 5 (menggunakan CURSOR): mengecek skripsi yang berpotensi terlambat
-- (sudah diajukan lebih dari 180 hari tetapi belum lulus/tidak lulus)
CREATE PROCEDURE sp_cek_keterlambatan_sidang()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_id_skripsi INT;
    DECLARE v_nim VARCHAR(15);
    DECLARE v_tanggal_pengajuan DATE;

    DECLARE cur_skripsi_terlambat CURSOR FOR
        SELECT id_skripsi, nim, tanggal_pengajuan
        FROM skripsi
        WHERE status NOT IN ('Lulus', 'Tidak Lulus')
          AND DATEDIFF(CURDATE(), tanggal_pengajuan) > 180;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cur_skripsi_terlambat;

    baca_loop: LOOP
        FETCH cur_skripsi_terlambat INTO v_id_skripsi, v_nim, v_tanggal_pengajuan;
        IF v_done = 1 THEN
            LEAVE baca_loop;
        END IF;

        INSERT INTO audit_log(nama_tabel, aksi, id_terkait, keterangan)
        VALUES ('skripsi', 'PERINGATAN_KETERLAMBATAN', v_id_skripsi,
                CONCAT('Mahasiswa ', v_nim, ' berpotensi terlambat, diajukan sejak ', v_tanggal_pengajuan));
    END LOOP;

    CLOSE cur_skripsi_terlambat;
END$$

DELIMITER ;
