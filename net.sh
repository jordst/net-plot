#!/bin/sh
# Mb = 1048576;
# kb = 1024;
if [ $1 ]; then
    [ $1 = "mb" ] && con=1048576
    [ $1 = "kb" ] && con=1024
else
    con=1024
fi
prx=-1
count=0
[ -f /tmp/data.dat  ] && cat /dev/null > /tmp/data.dat
int=$(route | grep default | awk '{print $8}')
time=$(date +%d:%m:%y\-%H:%M:%S)
filename="plot-$time.png"

while true; do
    rx=`cat /sys/class/net/$int/statistics/rx_bytes`
    tx=`cat /sys/class/net/$int/statistics/tx_bytes`

    if [ $prx -ne -1 ]; then
        rxs=$(echo $rx $prx $con | awk '{printf "%.2f", ($1-$2)/$3}')
        txs=$(echo $tx $ptx $con | awk '{printf "%.2f", ($1-$2)/$3}')
        [ $(echo $rxs) = "0.00" ] && rxs="0.01"
        [ $(echo $txs) = "0.00" ] && txs="0.01"
        echo -ne "$(date +%d/%m/%y\ %H:%M:%S) $rxs $txs\n" >> /tmp/data.dat
    fi

    prx=$rx
    ptx=$tx

    if [ $count -eq 5 ]; then
        lines=$(cat /tmp/data.dat | wc -l)
        let "lines-=1"
        $(cat /tmp/data.dat | tail -n $lines | tee /tmp/data.dat)
        count=0
    fi

    $(./plot.pg > ./pics/$filename)
    (( count=count+1 ))
    sleep 1
done
