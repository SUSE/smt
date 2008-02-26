#!/bin/sh
cat smt.spec | grep "^Requires" | awk '{print $2 }' | xargs

