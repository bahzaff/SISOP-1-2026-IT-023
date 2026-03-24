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

**KENDALA**

tidak ada kendala

## SOAL 2

Langkah pertama adalah membuat virtual environment (venv) Python agar instalasi package terisolasi dan tidak mempengaruhi sistem. Venv dibuat di luar folder repo agar tidak ikut ter-push ke GitHub

`1a. Install gdown dan Download PDF`

Setelah venv aktif, diinstall gdown yaitu tools Python yang memungkinkan download file dari Google Drive lewat terminal. Setelah gdown terinstall, dibuat folder ekspedisi dan file PDF peta diunduh ke dalamnya.
```bash
# Buat virtual environment di luar repo
python3 -m venv ~/sisop-venv

# Aktifkan venv
source ~/sisop-venv/bin/activate

# Install gdown di dalam venv
pip install gdown

# Verifikasi gdown jalan dari dalam venv
which gdown

# Buat folder dan download PDF
mkdir -p soal_2/ekspedisi
cd soal_2/ekspedisi
gdown "https://drive.google.com/uc?id=1q10pHSC3KFfvEiCN3V6PTroPR7YGHF6Q" -O peta-ekspedisi-amba.pdf
```

`1b. Membaca Isi PDF (Concatenate)`

membaca isi file PDF untuk menemukan tautan yang tersembunyi di dalamnya. Karena PDF menyimpan teks dalam format binary, digunakan perintah cat yang dikombinasikan dengan grep untuk memfilter baris yang mengandung URL atau link GitHub.


```bash
cat peta-ekspedisi-amba.pdf | grep -a "github\|https\|http"
```
Dari perintah tersebut ditemukan link repo:
 `https://github.com/pocongcyber77/peta-gunung-kawi.git`

`1c. Install Git dan Clone Repo`

Setelah tautan ditemukan, repo tersebut tidak bisa diunduh menggunakan gdown karena bukan file Google Drive, melainkan sebuah repository Git. Oleh karena itu digunakan perintah git clone untuk mengunduh seluruh isi repo ke dalam folder ekspedisi.
```bash
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git
```

`1d. Hasil Clone Repo`

Setelah proses clone selesai, folder peta-gunung-kawi berhasil dibuat di dalam folder ekspedisi. Di dalam folder tersebut terdapat file gsxtrack.json yang berisi data koordinat 4 titik lokasi bekas ekspedisi paman. Isi dari gsxtrack.json dapat dilihat sebagai berikut:
```bash
cat peta-gunung-kawi/gsxtrack.json
```
File tersebut berisi 4 node dengan masing-masing memiliki data id, site_name, latitude, longitude, elevation_m, dan status.

`2a. Membuat parserkoordinat.sh`

Langkah pertama adalah memahami struktur file gsxtrack.json yang berisi 4 node lokasi dengan data id, site_name, latitude, dan longitude. Untuk mengekstrak data tersebut, dibuat shell script parserkoordinat.sh yang menggunakan kombinasi grep dan awk dengan regex untuk mengambil nilai-nilai yang dibutuhkan dari setiap node. Hasilnya disimpan ke file titik-penting.txt dengan format id, site_name, latitude, longitude dan diurutkan berdasarkan id menggunakan sort.
```bash
#!/bin/bash

grep -E '"id"|"site_name"|"latitude"|"longitude"' gsxtrack.json | \
awk '
  /"id"/        { match($0, /"id": "([^"]+)"/, arr); id=arr[1] }
  /"site_name"/ { match($0, /"site_name": "([^"]+)"/, arr); site=arr[1] }
  /"latitude"/  { match($0, /"latitude": ([^,]+)/, arr); lat=arr[1] }
  /"longitude"/ { match($0, /"longitude": ([^,]+)/, arr); lon=arr[1];
                  print id", "site", "lat", "lon }
' | sort > titik-penting.txt

cat titik-penting.txt
```

`2b. Membuat nemupusaka.sh`

Setelah titik-penting.txt berhasil dibuat, langkah berikutnya adalah menghitung titik tengah dari keempat koordinat tersebut.digunakan metode titik simetri diagonal yaitu menghitung titik tengah dari dua koordinat yang saling berseberangan (node_001 dan node_003).cript membaca baris pertama (NR==1) dan baris ketiga (NR==3) dari titik-penting.txt sebagai pasangan diagonal, lalu menghitung rata-ratanya menggunakan awk dan menyimpan hasilnya ke posisipusaka.txt.
#!/bin/bash
```bash
awk -F', ' '
  NR==1 { x1=$4; y1=$3 }
  NR==3 { x2=$4; y2=$3 }
  END {
    lat = (y1+y2)/2
    lon = (x1+x2)/2
    printf "Koordinat pusat: %.6f, %.6f\n", lat, lon
  }
' titik-penting.txt > posisipusaka.txt

cat posisipusaka.txt
```
**OUTPUT SOAL 2**

`gdown`

![output a](assets/gdown.png)

`Download PDF`

![output a](assets/download%20pdf.png)

`PDF di folder`

![output a](assets/ls%20ekspedisi.png)

`Membaca isi PDF`

![output a](assets/grep%20pdf.png)

`Isi folder hasil clone`

![output a](assets/ls%20peta%20gunung%20kawi.png)

`Isi gsxtrack.json`

![output a](assets/cat%20gst1.png)
![output a](assets/cat%20gst2.png)

`output titik penting.txt`

![output a](assets/parser.png)

`output posisipusaka.txt`

![output a](assets/nemu.png)

**KENDALA**
venv sempat masuk di folder repository jadi tree nya berantakan











