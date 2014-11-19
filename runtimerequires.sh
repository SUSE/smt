#!/bin/sh
cat package/smt.spec | grep "^Requires" | awk '{print $2 }' | xargs

