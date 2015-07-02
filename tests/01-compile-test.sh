#!/bin/bash

DIR=$(dirname $0)

echo "Compile checking perl modules"
find "$DIR/../" -name *.pm -exec perl -I "$DIR/../www/perl-lib" -I "$DIR/../client/perl-lib" -c {} \;

echo "Compile checking scripts"
find "$DIR/../script" -executable -type f -exec perl -I "$DIR/../www/perl-lib" -I "$DIR/../client/perl-lib" -c {} \;