#!/bin/bash
PWDIR="$( cd "$( dirname "$0" )" && pwd )"
while true
do
    bash "$PWDIR"/ddos.sh
    sleep 10
done