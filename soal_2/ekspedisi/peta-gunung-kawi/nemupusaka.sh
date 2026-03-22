#!/bin/bash

awk -F', ' '
NR==1 { x1=$4; y1=$3 }
NR==3 { x2=$4; y2=$3 }
END {
    lat=(y1+y2)/2
    lon=(x1+x2)/2
    printf "Koordinat pusat: %.6f, %.6f\n", lat, lon
}
' titik-penting.txt > posisipusaka.txt

cat posisipusaka.txt
