BEGIN {
    FS = ","
    mode = ARGV[2]
    delete ARGV[2]
}

NR == 1 || NF == 0 { next }

{
    
    gsub(/\r/, "", $4)
    
    
    if ($4 != "") {
        count++
        total_age += $2
        gerbong[$4] = 1

        if ($2 > max_age) {
            max_age = $2
            oldest = $1
        }

        if ($3 == "Business") business++
    }
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
        if (count > 0) {
            avg = int(total_age / count)
            print "Rata-rata usia penumpang adalah " avg " tahun"
        }
    }
    else if (mode == "e") {
        print "Jumlah penumpang business class ada " business " orang"
    }
}
