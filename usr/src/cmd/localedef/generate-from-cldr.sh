#!/bin/sh -e

# Given a directory containing unpacked "core.zip" and "tools.zip" from CLDR,
# this script generates charmap (data/*.cm) and localedef input (data/*.src)
# files.

[ -n "$1" ] || { echo "usage: $0 cldr-directory" >&2; exit 1; }
CLDR="java -DCLDR_DIR=$1 -jar ${1}/tools/java/cldr.jar"

for charmap in $(cut -d. -f2 locales.txt | sort | uniq); do
    $CLDR org.unicode.cldr.posix.GenerateCharmap -d data -c $charmap
done

mkdir -p tmp
while read locale; do
    base=${locale%.*}
    charmap=${locale#*.}
    repertoire=
    if [ "$charmap" = "UTF-8" ]; then
        # BMP (minus surrogate pairs), SMP and SIP Unicode points
        repertoire='-u[[\u0000-\ud7ff][\ue000-\U0002FFFF]]'
    fi
    $CLDR org.unicode.cldr.posix.GeneratePOSIX -d tmp "$repertoire" -m $base -c $charmap
done < locales.txt

./collapse-locales.sh
rm -r tmp
