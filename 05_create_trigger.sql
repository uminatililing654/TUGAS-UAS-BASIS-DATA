-- =====================================================================
-- 05. TRIGGER
-- 4 trigger: trg_validasi_nilai_sidang, trg_update_status_setelah_sidang,
--            trg_audit_update_skripsi, trg_audit_insert_sidang
-- =====================================================================

USE db_skripsi_mahasiswa;

DELIMITER $$

-- Trigger 1 (Exception Handling): validasi rentang nilai sebelum sidang disimpan,
-- sekaligus mengisi status_kelulusan pada baris sidang itu sendiri
CREATE TRIGGER trg_validasi_nilai_sidang
BEFORE INSERT ON sidang
FOR EACH ROW
BEGIN
    IF NEW.nilai < 0 OR NEW.nilai > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nilai sidang tidak valid, harus di antara 0 dan 100';
    END IF;
    SET NEW.status_kelulusan = fn_status_kelulusan(NEW.nilai);
END$$

-- Trigger 2: setelah nilai sidang masuk, otomatis update status skripsi
CREATE TRIGGER trg_update_status_setelah_sidang
AFTER INSERT ON sidang
FOR EACH ROW
BEGIN
    UPDATE skripsi
    SET status = NEW.status_kelulusan
    WHERE id_skripsi = NEW.id_skripsi;
END$$

-- Trigger 3 (Audit Logging): mencatat setiap perubahan status skripsi
CREATE TRIGGER trg_audit_update_skripsi
AFTER UPDATE ON skripsi
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO audit_log(nama_tabel, aksi, id_terkait, keterangan)
        VALUES ('skripsi', 'UPDATE', NEW.id_skripsi,
                CONCAT('Status berubah dari ', OLD.status, ' menjadi ', NEW.status));
    END IF;
END$$

-- Trigger 4 (Audit Logging): mencatat setiap sidang baru yang diinput
CREATE TRIGGER trg_audit_insert_sidang
AFTER INSERT ON sidang
FOR EACH ROW
BEGIN
    INSERT INTO audit_log(nama_tabel, aksi, id_terkait, keterangan)
    VALUES ('sidang', 'INSERT', NEW.id_sidang,
            CONCAT('Sidang skripsi id ', NEW.id_skripsi, ' dengan nilai ', NEW.nilai));
END$$

DELIMITER ;
