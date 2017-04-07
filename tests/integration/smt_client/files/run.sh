#!/bin/bash

while [ "$(wget -qO - http://smt-server/status)" != "OK" ]; do
    echo "$(date) - still waiting for SMT server to sync"
    sleep 5
done

SUSEConnect --url http://smt-server/

exec "$@"
