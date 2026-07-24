-- =====================================================================
-- 02. CREATE TABLES
-- 6 tabel: mahasiswa, dosen, skripsi, bimbingan, sidang, audit_log
-- 4 relasi: mahasiswa-skripsi, dosen-skripsi, skripsi-bimbingan, skripsi-sidang
-- =====================================================================

USE db_skripsi_mahasiswa;

CREATE TABLE mahasiswa (
    nim             VARCHAR(15)  PRIMARY KEY,
    nama            VARCHAR(100) NOT NULL,
    program_studi   VARCHAR(50)  NOT NULL,
    angkatan        YEAR         NOT NULL,
    email           VARCHAR(100) UNIQUE,
    no_hp           VARCHAR(20)
);

CREATE TABLE dosen (
    nip              VARCHAR(20)  PRIMARY KEY,
    nama             VARCHAR(100) NOT NULL,
    bidang_keahlian  VARCHAR(100),
    email            VARCHAR(100) UNIQUE
);

CREATE TABLE skripsi (
    id_skripsi         INT AUTO_INCREMENT PRIMARY KEY,
    nim                VARCHAR(15) NOT NULL,
    nip_pembimbing     VARCHAR(20) NOT NULL,
    judul              VARCHAR(255) NOT NULL,
    tanggal_pengajuan  DATE NOT NULL,
    status             ENUM('Diajukan','Bimbingan','Siap Sidang','Lulus','Tidak Lulus')
                        NOT NULL DEFAULT 'Diajukan',
    CONSTRAINT fk_skripsi_mahasiswa FOREIGN KEY (nim) REFERENCES mahasiswa(nim),
    CONSTRAINT fk_skripsi_dosen FOREIGN KEY (nip_pembimbing) REFERENCES dosen(nip)
);

CREATE TABLE bimbingan (
    id_bimbingan      INT AUTO_INCREMENT PRIMARY KEY,
    id_skripsi        INT NOT NULL,
    tanggal_bimbingan DATE NOT NULL,
    catatan           TEXT,
    progres           ENUM('Revisi','Selesai') NOT NULL DEFAULT 'Revisi',
    CONSTRAINT fk_bimbingan_skripsi FOREIGN KEY (id_skripsi) REFERENCES skripsi(id_skripsi)
);

CREATE TABLE sidang (
    id_sidang       INT AUTO_INCREMENT PRIMARY KEY,
    id_skripsi      INT NOT NULL,
    tanggal_sidang  DATE NOT NULL,
    nilai           DECIMAL(5,2) NOT NULL,
    status_kelulusan VARCHAR(20),
    CONSTRAINT fk_sidang_skripsi FOREIGN KEY (id_skripsi) REFERENCES skripsi(id_skripsi)
);

CREATE TABLE audit_log (
    id_log      INT AUTO_INCREMENT PRIMARY KEY,
    nama_tabel  VARCHAR(50) NOT NULL,
    aksi        VARCHAR(30) NOT NULL,
    id_terkait  INT,
    waktu       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    keterangan  TEXT
);
