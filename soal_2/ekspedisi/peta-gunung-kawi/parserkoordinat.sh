#!/bin/bash

grep -E '"id"|"site_name"|"latitude"|"longitude"' gsxtrack.json | \
awk '
/"id"/ { match($0, /"id": "([^"]+)"/, arr); id=arr[1] }
/"site_name"/ { match($0, /"site_name": "([^"]+)"/, arr); site=arr[1] }
/"latitude"/ { match($0, /"latitude": ([^,]+)/, arr); lat=arr[1] }
/"longitude"/ { match($0, /"longitude": ([^,]+)/, arr); lon=arr[1]; print id", "site", "lat", "lon }
' | sort > titik-penting.txt

cat titik-penting.txt
