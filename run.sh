#!/bin/bash
clear
echo "Start protecting..."
if [ "${1}x" = "--testx" ]; then
	echo "[Test mode]"
fi
PWDIR="$( cd "$( dirname "$0" )" && pwd )"
while true
do
    bash "$PWDIR"/ddos.sh $1 &
    sleep 10
done