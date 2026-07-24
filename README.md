# Sistem Basis Data Skripsi/Tugas Akhir Mahasiswa

Proyek Evaluasi Akhir Semester (EAS) mata kuliah **Pemrograman Basis Data** — Program Studi S1 Informatika, Semester 4.

Topik: Integrasi Stored Procedure, Function, Trigger, Cursor, Transaction Control, Exception Handling, dan Indexing dalam satu sistem basis data terintegrasi.

## Kelompok 11

- Uminati
- Lilis
- Nuraisya
- Lisa

## Deskripsi

Sistem ini mengelola alur pengajuan hingga sidang skripsi mahasiswa: pendaftaran judul dan dosen pembimbing, pencatatan sesi bimbingan, penjadwalan sidang, input dan validasi nilai, hingga pencatatan audit atas setiap perubahan status skripsi. Seluruh aturan bisnis ditanamkan langsung pada level basis data (bukan di aplikasi), sehingga konsisten dijalankan siapa pun yang mengaksesnya.

## Struktur Basis Data

**6 tabel, 4 relasi:**

| Tabel | Keterangan |
|---|---|
| `mahasiswa` | Data induk mahasiswa |
| `dosen` | Data induk dosen pembimbing |
| `skripsi` | Tabel utama — menghubungkan mahasiswa & dosen, menyimpan judul dan status progres |
| `bimbingan` | Riwayat sesi konsultasi/bimbingan per skripsi |
| `sidang` | Hasil penilaian sidang per skripsi |
| `audit_log` | Jejak perubahan status, diisi otomatis oleh trigger |

```
mahasiswa (1) ──< (N) skripsi (N) >── (1) dosen
                       │
                       ├──< (N) bimbingan
                       └──< (N) sidang
```

## Objek Basis Data yang Diimplementasikan

| Objek | Jumlah | Nama |
|---|---|---|
| Stored Procedure | 5 | `sp_daftar_skripsi`, `sp_tambah_bimbingan`, `sp_jadwalkan_sidang`, `sp_input_nilai_sidang`, `sp_cek_keterlambatan_sidang` |
| Function | 3 | `fn_hitung_jumlah_bimbingan`, `fn_status_kelulusan`, `fn_durasi_penyelesaian` |
| Trigger | 4 | `trg_validasi_nilai_sidang`, `trg_update_status_setelah_sidang`, `trg_audit_update_skripsi`, `trg_audit_insert_sidang` |
| Cursor | 1 | Di dalam `sp_cek_keterlambatan_sidang` |
| Exception Handling | 3 skenario | Kuota dosen pembimbing, syarat minimal bimbingan, validasi rentang nilai |
| Transaction Control | ✓ | `START TRANSACTION`, `SAVEPOINT`, `COMMIT`, `ROLLBACK TO SAVEPOINT` (di `sp_daftar_skripsi`) |
| Index | 3 | `idx_nama_mahasiswa`, `idx_tanggal_sidang`, `idx_status_skripsi` |
| Audit Log | 1 tabel | `audit_log`, diisi otomatis oleh trigger |
| Data Uji | 36 baris | mahasiswa, dosen, skripsi, bimbingan, sidang |

## Struktur Repository

```
.
├── sql/
│   ├── 01_create_database.sql        # buat database
│   ├── 02_create_tables.sql          # 6 tabel + relasi (PK/FK)
│   ├── 03_create_index.sql           # 3 index
│   ├── 04_create_function.sql        # 3 function
│   ├── 05_create_trigger.sql         # 4 trigger
│   ├── 06_create_procedure.sql       # 5 procedure (transaction control + exception handling)
│   ├── 07_data_dummy.sql             # data uji (36+ baris)
│   └── 08_contoh_query_pengujian.sql # query contoh untuk BAB IV
├── call_procedures_demo.sql          # kumpulan CALL untuk demo (alur normal + skenario error)
├── docs/
│   └── erd.png                       # diagram ERD
└── README.md
```

## Cara Menjalankan

**Kebutuhan:** MySQL 8.x atau MariaDB 10.x

Jalankan kedelapan file di folder `sql/` secara berurutan (nomor 01–08), karena setiap file bergantung pada objek yang dibuat file sebelumnya:

```bash
cd sql
for f in 01_create_database.sql 02_create_tables.sql 03_create_index.sql \
         04_create_function.sql 05_create_trigger.sql 06_create_procedure.sql \
         07_data_dummy.sql 08_contoh_query_pengujian.sql; do
  mysql -u root -p < "$f"
done
```

Atau gabungkan langsung lewat `cat`:

```bash
cat sql/01_create_database.sql sql/02_create_tables.sql sql/03_create_index.sql \
    sql/04_create_function.sql sql/05_create_trigger.sql sql/06_create_procedure.sql \
    sql/07_data_dummy.sql sql/08_contoh_query_pengujian.sql | mysql -u root -p
```

Setelah selesai, database `db_skripsi_mahasiswa` akan berisi seluruh tabel, procedure, function, trigger, index, dan data uji.

## Cara Demo

Setelah database ter-load, jalankan kumpulan pemanggilan berikut:

```bash
mysql -u root -p --force < call_procedures_demo.sql
```

File ini berisi dua bagian:

- **Bagian A — Alur normal**: pendaftaran skripsi → bimbingan → penjadwalan sidang → input nilai → pengecekan keterlambatan (cursor). Menunjukkan seluruh procedure, function, dan trigger bekerja.
- **Bagian B — Skenario exception handling**: percobaan yang sengaja dibuat gagal (melebihi kuota dosen, sidang sebelum cukup bimbingan, nilai di luar rentang 0-100) untuk membuktikan validasi bisnis benar-benar ditegakkan di level basis data.

Flag `--force` diperlukan agar eksekusi tetap lanjut walau ada error yang memang disengaja pada Bagian B. Untuk demo interaktif satu per satu (mis. di MySQL client atau phpMyAdmin), flag ini tidak diperlukan.

## Contoh Query Verifikasi

```sql
-- Data skripsi terintegrasi (JOIN + function)
SELECT s.id_skripsi, m.nama, d.nama AS pembimbing, s.status,
       fn_hitung_jumlah_bimbingan(s.id_skripsi) AS total_bimbingan
FROM skripsi s
JOIN mahasiswa m ON s.nim = m.nim
JOIN dosen d ON s.nip_pembimbing = d.nip;

-- Riwayat audit log
SELECT * FROM audit_log ORDER BY id_log DESC LIMIT 10;
```

## Lisensi

Proyek ini dibuat untuk keperluan akademik (Evaluasi Akhir Semester) dan tidak dimaksudkan untuk penggunaan produksi.
