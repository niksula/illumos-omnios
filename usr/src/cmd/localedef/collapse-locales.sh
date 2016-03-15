#!/bin/sh -e


cd tmp
for f in *.src; do
    nawk 'BEGIN { s = 0; }
    /^LC_CTYPE$/ { s = 1 }
    s == 1 { print >"'$f'.LC_CTYPE"; }
    /^END LC_CTYPE$/ { s = 0; next; }
    /^LC_COLLATE$/ { s = 2 }
    s == 2 { print >"'$f'.LC_COLLATE"; }
    /^END LC_COLLATE$/ { s = 0; next; }
    s == 0 { print; }
    ' > ${f}.collapsed < $f
done
for file in *.LC_CTYPE *.LC_COLLATE; do
    dgst=$(digest -a sha256 $file)
    locale=${file%.src.*}
    category=${file#*.src.}
    catfile="../data/${category}.${dgst}"
    if ! [ -f "$catfile" ]; then
        cp $file $catfile
    else
        cmp $file $catfile || { echo "fatal: hash collision" >&2; exit 1; }
    fi
    ln -sf ${category}.${dgst} ../data/${locale}.${category}
    cp ${locale}.src.collapsed ../data/${locale}.src
done
