#!/bin/sh
cat package/smt.spec | grep "^BuildRequires" | awk '{print $2 }' | xargs

