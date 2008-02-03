#!/bin/sh
cat yep.spec | grep "^Requires" | awk '{print $2 }' | xargs

