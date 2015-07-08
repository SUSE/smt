#!/bin/bash

DIR=$(dirname $0)

res=0
for ldir in 'www' 'client'; do
    echo "Checking $ldir"
    echo "Compile checking perl modules"
    find "$DIR/../$ldir/perl-lib" -name *.pm -exec perl -I "$DIR/../www/perl-lib" -I "$DIR/../client/perl-lib" -c '{}' \;

    echo "Compile checking scripts"
    if [ ! -d "$DIR/../$ldir/script" ]; then
        ldir="$ldir/../"
    fi
    for f in `find "$DIR/../$ldir/script" -executable -type f`; do
        t=$(file "$f")
        if echo "$t" | grep -q Perl; then
            f=$(echo "$t" | cut -d: -f1)
            perl -I "$DIR/../www/perl-lib" -I "$DIR/../client/perl-lib" -c "$f" || res=1
        elif echo "$t" | grep -q Bourne; then
            f=$(echo "$t" | cut -d: -f1)
            bash -n "$f" && echo "$f syntax OK" || (echo "$f syntax FAIL" && res=1)
        fi
    done
done

exit $res
