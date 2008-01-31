#!/bin/bash

free=$(free | grep ^Mem: | awk '{ print $4; }')
maxclients=$[ $free / 10240 ]
progname=${0##*/}

if [ -z "$1" -o -z "$2" -o "$1" = "-h" ]; then 
   echo "usage: $progname <number of concurrent clients> <number of registrations per client>"
   exit 1
fi

concurrency=$1
registrations=$2

if [ $maxclients -lt $concurrency ]; then
   echo "too much clients requested (max=$maxclients) ... aborting."
   exit 1
else
   echo "launching $concurrency clients"
fi

for i in `seq 0 $[ $concurrency - 1 ]`
do
	mkdir -p run-$i
	pushd run-$i > /dev/null || continue
        start=$[ $i * $registrations ]
        end=$[ $start + $registrations - 1 ]
        echo "launching ../register_performance.pl $start $end"
	../register_performance.pl $start $end &
	popd > /dev/null || continue
done 2>&1 | tee log
