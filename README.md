# SISOP-1-2026-IT-023

# NAMA
Barra Ahza Fakhrullah 5027251023

# LAPORAN
## SOAL 1

Langkah pertama sebelum mengerjakan semua sub-soal adalah menyiapkan blok BEGIN untuk menginisialisasi field separator dan membaca argumen mode dari ARGV[2]. ARGV[2] kemudian dihapus menggunakan delete agar AWK tidak mencoba membuka argumen tersebut sebagai file.
``` awk
BEGIN { FS=","; mode=ARGV[2]; delete ARGV[2] }
```
Setelah itu, karena baris pertama file passenger.csv adalah header (Nama Penumpang, Usia, Kursi Kelas, Gerbong), maka baris pertama perlu di-skip menggunakan NR==1 { next } agar tidak ikut dihitung
``` awk
NR == 1 { next }
```
`a. Total Penumpang`

Untuk menghitung total penumpang, setiap kali AWK membaca satu baris data, variabel count ditambah 1. Karena header sudah di-skip, maka setiap baris yang dibaca pasti merupakan data penumpang. Di blok END, jika mode adalah 'a' maka nilai count langsung dicetak sebagai output.
``` awk
{ count++ }
END {
    if (mode == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " count " orang"
    }
}
```
`b. Jumlah Gerbong Unik`

Untuk menghitung gerbong unik, digunakan array associatif AWK. Setiap baris data, kolom keempat ($4) yang berisi nama gerbong dijadikan sebagai index array dengan nilai 1. Karena array associatif AWK otomatis mengabaikan duplikat (index yang sama hanya disimpan sekali), maka di blok END cukup menggunakan fungsi length() untuk mengetahui berapa banyak gerbong unik yang ada.
``` awk
{ gerbong[$4] = 1 }

END {
    else if (mode == "b") {
        print "Jumlah gerbong penumpang KANJ adalah " length(gerbong)
    }
}
```
`c. Penumpang Tertua`

Untuk menemukan penumpang tertua, setiap baris data dibandingkan nilai kolom kedua ($2) yang berisi usia dengan nilai max_age yang disimpan sementara. Jika usia pada baris saat ini lebih besar dari max_age, maka max_age diperbarui dan nama penumpang ($1) disimpan ke variabel oldest. Proses ini berjalan terus hingga semua baris selesai dibaca, sehingga di blok END variabel oldest sudah pasti berisi nama penumpang dengan usia tertinggi.
``` awk
{
    if ($2 > max_age) {
        max_age = $2
        oldest = $1
    }
}

END {
    else if (mode == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    }
}
```
`d. Rata-rata Usia`

Untuk menghitung rata-rata usia, setiap baris data dijumlahkan nilai kolom kedua ($2) ke dalam variabel total_age. Di blok END, total_age dibagi dengan count untuk mendapatkan rata-rata. Karena soal meminta hasil tanpa angka di belakang koma, digunakan fungsi int() untuk membulatkan hasil pembagian tersebut sebelum dicetak.
``` awk
{ total_age += $2 }

END {
    else if (mode == "d") {
        avg = int(total_age / count)
        print "Rata-rata usia penumpang adalah " avg " tahun"
    }
}
```
`e. Penumpang Business Class`

Untuk menghitung jumlah penumpang Business Class, setiap baris data dicek nilai kolom ketiga ($3) yang berisi kelas kursi. Jika nilainya adalah 'Business', maka variabel business ditambah 1. Di blok END, jika mode adalah 'e' maka nilai business langsung dicetak sebagai output.
``` awk
{ if ($3 == "Business") business++ }

END {
    else if (mode == "e") {
        print "Jumlah penumpang business class ada " business " orang"
    }
}
```
`f. Invalid Option`

Untuk menangani kasus di mana user memasukkan argumen selain a, b, c, d, atau e, blok END menggunakan else di paling akhir sebagai fallback. Jika mode tidak cocok dengan satupun kondisi sebelumnya, maka akan dicetak pesan error beserta contoh penggunaan yang benar agar user mengetahui cara pemakaian script yang tepat.
``` awk
END {
    else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh data.csv a"
    }
}
```
**OUTPUT SOAL 1**

`a. Total Penumpang`

![output a](assets/1a.png)


`b. Jumlah Gerbong Unik`

![output a](assets/1b.png)


`c. Penumpang Tertua`

![output a](assets/1c.png)

`d. Rata-rata Usia`

![output a](assets/1d.png)

`e. Penumpang Business Class`

![output a](assets/1e.png)

`f. Invalid Option`

![output a](assets/1z.png)












