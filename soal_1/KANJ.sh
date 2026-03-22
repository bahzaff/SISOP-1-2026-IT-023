BEGIN {
    FS = ","
    mode = ARGV[2]
    delete ARGV[2]
}

NR == 1 { next }

{
    count++
    total_age += $2
    if ($2 > max_age) {
        max_age = $2
        oldest = $1
    }
    gerbong[$4] = 1
    if ($3 == "Business") business++
}

END {
    if (mode == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " count " orang"
    }
    else if (mode == "b") {
        print "Jumlah gerbong penumpang KANJ adalah " length(gerbong)
    }
    else if (mode == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    }
    else if (mode == "d") {
        avg = int(total_age / count)
        print "Rata-rata usia penumpang adalah " avg " tahun"
    }
    else if (mode == "e") {
        print "Jumlah penumpang business class ada " business " orang"
    }
    else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh data.csv a"
    }
}
