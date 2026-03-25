#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

FILE_DATA="$DIR/data/penghuni.csv"
FILE_LOG="$DIR/log/tagihan.log"
FILE_REKAP="$DIR/rekap/laporan_bulanan.txt"
FILE_SAMPAH="$DIR/sampah/history_hapus.csv"

if [ "$1" == "--check-tagihan" ]; then
    WAKTU_SEKARANG=$(date +"%Y-%m-%d %H:%M:%S")
    
    if [ -f "$FILE_DATA" ]; then
        awk -F',' -v waktu="$WAKTU_SEKARANG" -v logfile="$FILE_LOG" '
        tolower($5) == "menunggak" {
            printf "[%s] TAGIHAN: %s (Kamar %s) - Menunggak Rp%s\n", waktu, $1, $2, $3 >> logfile
        }' "$FILE_DATA"
    fi
    exit 0
fi

fungsi_tambah() {
    clear
    echo "======================================================="
    echo "                    TAMBAH PENGHUNI                    "
    echo "======================================================="
    
    read -p "Masukkan Nama: " nama
    
    while true; do
        read -p "Masukkan Kamar: " kamar
        if [ ! -f "$FILE_DATA" ]; then
            touch "$FILE_DATA"
        fi
        cek_kamar=$(awk -F',' -v k="$kamar" '$2 == k {print "ada"}' "$FILE_DATA")
        if [ "$cek_kamar" == "ada" ]; then
            echo "[!] Error: Kamar $kamar sudah terisi! Pilih kamar lain."
        else
            break
        fi
    done
    
    while true; do
        read -p "Masukkan Harga Sewa: " harga
        if [[ "$harga" =~ ^[0-9]+$ ]] && [ "$harga" -gt 0 ]; then
            break
        else
            echo "[!] Error: Harga sewa harus angka positif!"
        fi
    done
    
    sekarang=$(date -d "$(date +%Y-%m-%d)" +%s)
    while true; do
        read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal
        if date -d "$tanggal" >/dev/null 2>&1; then
            format_tgl=$(date -d "$tanggal" +%Y-%m-%d)
            if [ "$tanggal" == "$format_tgl" ]; then
                input_epoch=$(date -d "$tanggal" +%s)
                if [ "$input_epoch" -le "$sekarang" ]; then
                    break
                else
                    echo "[!] Error: Tanggal tidak boleh melebihi hari ini (masa depan)!"
                fi
            else
                echo "[!] Error: Format tanggal harus persis YYYY-MM-DD!"
            fi
        else
            echo "[!] Error: Format/Tanggal tidak valid!"
        fi
    done
    
    while true; do
        read -p "Masukkan Status Awal (Aktif/Menunggak): " status
        if [[ "${status,,}" == "aktif" ]]; then
            status="Aktif"
            break
        elif [[ "${status,,}" == "menunggak" ]]; then
            status="Menunggak"
            break
        else
            echo "[!] Error: Status harus 'Aktif' atau 'Menunggak'!"
        fi
    done
    
    echo "$nama,$kamar,$harga,$tanggal,$status" >> "$FILE_DATA"
    echo ""
    echo "[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
}

fungsi_hapus() {
    clear
    echo "======================================================="
    echo "                     HAPUS PENGHUNI                    "
    echo "======================================================="
    
    if [ ! -f "$FILE_DATA" ] || [ ! -s "$FILE_DATA" ]; then
        echo "[!] Database masih kosong. Belum ada penghuni."
        return
    fi
    
    read -p "Masukkan nama penghuni yang akan dihapus: " nama_hapus
    
    baris_data=$(awk -F',' -v n="$nama_hapus" 'tolower($1) == tolower(n) {print $0}' "$FILE_DATA")
    
    if [ -z "$baris_data" ]; then
        echo "[!] Error: Penghuni dengan nama \"$nama_hapus\" tidak ditemukan!"
    else
        tgl_hapus=$(date +%Y-%m-%d)
        
        echo "${baris_data},${tgl_hapus}" >> "$FILE_SAMPAH"
        
        awk -F',' -v n="$nama_hapus" 'tolower($1) != tolower(n)' "$FILE_DATA" > "${FILE_DATA}.tmp" && mv "${FILE_DATA}.tmp" "$FILE_DATA"
        
        echo ""
        echo "[√] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    fi
}

fungsi_tampil() {
    clear
    echo "======================================================="
    echo "              DAFTAR PENGHUNI KOST SLEBEW              "
    echo "======================================================="
    
    if [ ! -f "$FILE_DATA" ] || [ ! -s "$FILE_DATA" ]; then
        echo "[!] Database masih kosong. Belum ada penghuni."
        return
    fi
    
    echo "No | Nama       | Kamar | Harga Sewa      | Status"
    echo "-------------------------------------------------------"
    
    awk -F',' '
    function format_rp(num) {
        str = num; res = ""; len = length(str)
        for(i=1; i<=len; i++) {
            res = res substr(str, i, 1)
            if ((len-i)%3 == 0 && i != len) res = res "."
        }
        return res
    }
    BEGIN { count=0; aktif=0; nunggak=0 }
    {
        count++
        if (tolower($5) == "aktif") aktif++
        if (tolower($5) == "menunggak") nunggak++
        
        printf "%-2s | %-10s | %-5s | Rp%-13s | %s\n", count, $1, $2, format_rp($3), $5
    }
    END {
        print "-------------------------------------------------------"
        printf "Total: %d penghuni | Aktif: %d | Menunggak: %d\n", count, aktif, nunggak
        print "======================================================="
    }' "$FILE_DATA"
}

fungsi_update_status() {
    clear
    echo "======================================================="
    echo "                     UPDATE STATUS                     "
    echo "======================================================="
    
    if [ ! -f "$FILE_DATA" ] || [ ! -s "$FILE_DATA" ]; then
        echo "[!] Database masih kosong. Belum ada penghuni."
        return
    fi
    
    read -p "Masukkan Nama Penghuni: " nama_update
    
    cek_nama=$(awk -F',' -v n="$nama_update" 'tolower($1) == tolower(n) {print "ada"}' "$FILE_DATA")
    
    if [ "$cek_nama" != "ada" ]; then
        echo "[!] Error: Penghuni dengan nama \"$nama_update\" tidak ditemukan!"
        return
    fi
    
    while true; do
        read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru
        if [[ "${status_baru,,}" == "aktif" ]]; then
            status_baru="Aktif"
            break
        elif [[ "${status_baru,,}" == "menunggak" ]]; then
            status_baru="Menunggak"
            break
        else
            echo "[!] Error: Status harus 'Aktif' atau 'Menunggak'!"
        fi
    done
    
    awk -F',' -v n="$nama_update" -v s="$status_baru" 'BEGIN {OFS=","} {if(tolower($1) == tolower(n)) $5=s; print $0}' "$FILE_DATA" > "${FILE_DATA}.tmp" && mv "${FILE_DATA}.tmp" "$FILE_DATA"
    
    echo ""
    echo "[√] Status $nama_update berhasil diubah menjadi: $status_baru"
}

fungsi_cetak_laporan() {
    clear
    
    if [ ! -f "$FILE_DATA" ] || [ ! -s "$FILE_DATA" ]; then
        echo "[!] Database masih kosong. Belum ada penghuni."
        return
    fi
    
    laporan=$(awk -F',' '
    function format_rp(num) {
        str = num; res = ""; len = length(str)
        for(i=1; i<=len; i++) {
            res = res substr(str, i, 1)
            if ((len-i)%3 == 0 && i != len) res = res "."
        }
        return res
    }
    BEGIN {
        pemasukan = 0
        tunggakan = 0
        kamar_terisi = 0
        daftar_nunggak = ""
    }
    {
        kamar_terisi++
        if (tolower($5) == "aktif") {
            pemasukan += $3
        } else if (tolower($5) == "menunggak") {
            tunggakan += $3
            daftar_nunggak = daftar_nunggak "    " $1 "\n"
        }
    }
    END {
        print "======================================================="
        print "              LAPORAN KEUANGAN KOST SLEBEW             "
        print "======================================================="
        printf "Total pemasukan (Aktif) : Rp%s\n", format_rp(pemasukan)
        printf "Total tunggakan         : Rp%s\n", format_rp(tunggakan)
        printf "Jumlah kamar terisi     : %d\n", kamar_terisi
        print "-------------------------------------------------------"
        print "Daftar penghuni menunggak:"
        if (tunggakan == 0) {
            print "    Tidak ada tunggakan."
        } else {
            printf "%s", daftar_nunggak
        }
        print "======================================================="
    }' "$FILE_DATA")
    
    echo "$laporan"
    
    echo "$laporan" > "$FILE_REKAP"
    
    echo ""
    echo "[√] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
}
fungsi_update_status() {
    clear
    echo "======================================================="
    echo "                     UPDATE STATUS                     "
    echo "======================================================="
    
    if [ ! -f "$FILE_DATA" ] || [ ! -s "$FILE_DATA" ]; then
        echo "[!] Database masih kosong. Belum ada penghuni."
        return
    fi
    
    read -p "Masukkan Nama Penghuni: " nama_update
    
    cek_nama=$(awk -F',' -v n="$nama_update" 'tolower($1) == tolower(n) {print "ada"}' "$FILE_DATA")
    
    if [ "$cek_nama" != "ada" ]; then
        echo "[!] Error: Penghuni dengan nama \"$nama_update\" tidak ditemukan!"
        return
    fi
    
    while true; do
        read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru
        if [[ "${status_baru,,}" == "aktif" ]]; then
            status_baru="Aktif"
            break
        elif [[ "${status_baru,,}" == "menunggak" ]]; then
            status_baru="Menunggak"
            break
        else
            echo "[!] Error: Status harus 'Aktif' atau 'Menunggak'!"
        fi
    done
    
    awk -F',' -v n="$nama_update" -v s="$status_baru" 'BEGIN {OFS=","} {if(tolower($1) == tolower(n)) $5=s; print $0}' "$FILE_DATA" > "${FILE_DATA}.tmp" && mv "${FILE_DATA}.tmp" "$FILE_DATA"
    
    echo ""
    echo "[√] Status $nama_update berhasil diubah menjadi: $status_baru"
}

fungsi_cetak_laporan() {
    clear
    
    if [ ! -f "$FILE_DATA" ] || [ ! -s "$FILE_DATA" ]; then
        echo "[!] Database masih kosong. Belum ada penghuni."
        return
    fi
    
    laporan=$(awk -F',' '
    function format_rp(num) {
        str = num; res = ""; len = length(str)
        for(i=1; i<=len; i++) {
            res = res substr(str, i, 1)
            if ((len-i)%3 == 0 && i != len) res = res "."
        }
        return res
    }
    BEGIN {
        pemasukan = 0
        tunggakan = 0
        kamar_terisi = 0
        daftar_nunggak = ""
    }
    {
        kamar_terisi++
        if (tolower($5) == "aktif") {
            pemasukan += $3
        } else if (tolower($5) == "menunggak") {
            tunggakan += $3
            daftar_nunggak = daftar_nunggak "    " $1 "\n"
        }
    }
    END {
        print "======================================================="
        print "              LAPORAN KEUANGAN KOST SLEBEW             "
        print "======================================================="
        printf "Total pemasukan (Aktif) : Rp%s\n", format_rp(pemasukan)
        printf "Total tunggakan         : Rp%s\n", format_rp(tunggakan)
        printf "Jumlah kamar terisi     : %d\n", kamar_terisi
        print "-------------------------------------------------------"
        print "Daftar penghuni menunggak:"
        if (tunggakan == 0) {
            print "    Tidak ada tunggakan."
        } else {
            printf "%s", daftar_nunggak
        }
        print "======================================================="
    }' "$FILE_DATA")
    
    echo "$laporan"
    
    echo "$laporan" > "$FILE_REKAP"
    
    echo ""
    echo "[√] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
}

fungsi_kelola_cron() {
    while true; do
        clear
        echo "======================================================="
        echo "                    MENU KELOLA CRON                   "
        echo "======================================================="
        echo "1. Lihat Cron Job Aktif"
        echo "2. Daftarkan Cron Job Pengingat"
        echo "3. Hapus Cron Job Pengingat"
        echo "4. Kembali"
        echo "======================================================="
        
        read -p "Pilih [1-4]: " pilihan_cron
        echo ""
        
        # Absolute path script ini buat dimasukin ke crontab
        SCRIPT_PATH="$DIR/kost_slebew.sh"
        CRON_CMD="$SCRIPT_PATH --check-tagihan"
        
        case $pilihan_cron in
            1)
                echo "--- Daftar Cron Job Pengingat Tagihan ---"
                # grep dipakai untuk memfilter agar hanya nampilin cron milik script ini
                crontab -l 2>/dev/null | grep "$CRON_CMD" || echo "Belum ada cron job yang terdaftar."
                
                echo ""
                read -p "Tekan [ENTER] untuk kembali..."
                ;;
            2)
                read -p "Masukkan Jam (0-23): " jam
                read -p "Masukkan Menit (0-59): " menit
                
                if [[ ! "$jam" =~ ^[0-9]+$ ]] || [[ ! "$menit" =~ ^[0-9]+$ ]] || [ "$jam" -lt 0 ] || [ "$jam" -gt 23 ] || [ "$menit" -lt 0 ] || [ "$menit" -gt 59 ]; then
                    echo "[!] Error: Format jam atau menit tidak valid!"
                else
                    # Logika Overwrite/Update Cron:
                    # 1. Tarik semua cron yang ada, KECUALI yang punya script ini (grep -v)
                    # 2. Masukkan ke file sementara (cron_temp)
                    # 3. Tambahkan jadwal baru ke file sementara itu
                    # 4. Daftarkan ulang file sementara itu ke crontab
                    crontab -l 2>/dev/null | grep -v "$CRON_CMD" > cron_temp
                    echo "$menit $jam * * * $CRON_CMD" >> cron_temp
                    crontab cron_temp
                    rm cron_temp
                    
                    echo "[√] Cron job pengingat berhasil didaftarkan pada $jam:$menit setiap hari."
                fi
                echo ""
                read -p "Tekan [ENTER] untuk kembali..."
                ;;
            3)
                # Menghapus cukup dengan menarik semua cron kecuali milik script ini, lalu daftarkan ulang
                crontab -l 2>/dev/null | grep -v "$CRON_CMD" > cron_temp
                crontab cron_temp
                rm cron_temp
                
                echo "[√] Cron job pengingat tagihan berhasil dihapus."
                echo ""
                read -p "Tekan [ENTER] untuk kembali..."
                ;;
            4)
                # Keluar dari looping menu cron dan kembali ke menu utama
                break
                ;;
            *)
                echo "[!] Pilihan tidak valid!"
                read -p "Tekan [ENTER] untuk kembali..."
                ;;
        esac
    done
}


while true; do
    clear
    echo " /\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\ "
    echo "|  _  __         _      _____ _      _                     |"
    echo "| | |/ /___  ___| |_   / ____| |    | |                    |"
    echo "| | ' // _ \\/ __| __| | (___ | | ___| |__   _____      __  |"
    echo "| |  <| (_) \\__ \\ |_   \\___ \\| |/ _ \\ '_ \\ / _ \\ \\ /\\ / /  |"
    echo "| | . \\___/|___/\\__|  ____) | |  __/ |_) |  __/\\ V  V /   |"
    echo "| |_|\\_\\             |_____/|_|\\___|_.__/ \\___| \\_/\\_/    |"
    echo " \\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/ "
    echo ""
    echo "======================================================="
    echo "             SISTEM MANAJEMEN KOST SLEBEW              "
    echo "======================================================="
    echo "ID | OPTION"
    echo "-------------------------------------------------------"
    echo " 1 | Tambah Penghuni Baru"
    echo " 2 | Hapus Penghuni"
    echo " 3 | Tampilkan Daftar Penghuni"
    echo " 4 | Update Status Penghuni"
    echo " 5 | Cetak Laporan Keuangan"
    echo " 6 | Kelola Cron (Pengingat Tagihan)"
    echo " 7 | Exit Program"
    echo "======================================================="
    
    read -p "Enter option [1-7]: " pilihan
    
    case $pilihan in
        1) fungsi_tambah ;;
        2) fungsi_hapus ;;
        3) fungsi_tampil ;;
        4) fungsi_update_status ;;
        5) fungsi_cetak_laporan ;;
        6) fungsi_kelola_cron ;;
        7) 
            echo "Keluar dari program. Terima kasih!"
            exit 0 
            ;;
        *) 
            echo "Opsi tidak valid! Silakan pilih 1-7." 
            ;;
    esac
    
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
done
