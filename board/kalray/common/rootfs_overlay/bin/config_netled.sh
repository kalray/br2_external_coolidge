#!/bin/bash

ITF=$1
t=$(echo $ITF | tr -dc '0-9')
DEV=$(($t / 4))

pushd /sys/class/leds
for d in $(ls); do
    if cat "$d/uevent" | egrep -q eth${DEV}-activity ; then
        if [ $(</sys/class/net/$ITF/operstate) == "down" ]; then
            echo none > $d/trigger
            echo 0 > $d/brightness
            continue
        fi
        echo netdev > $d/trigger
        echo 1 > $d/link
        echo 1 > $d/tx
        echo 1 > $d/rx
        echo $ITF > $d/device_name
    elif cat "$d/uevent" | egrep -q eth${DEV}-physical ; then
        if [ $(</sys/class/net/$ITF/operstate) == "down" ]; then
            echo none > $d/trigger
            echo 0 > $d/brightness
            continue
        fi
        speed=$(</sys/class/net/$ITF/speed)
        if [ $speed == "40000" ]; then
            echo pattern > $d/trigger
            echo 0 1000 0 0 255 1000 255 0 > $d/pattern
        elif [ $speed == "100000" ]; then
            echo none > $d/trigger
            echo 255 > $d/brightness
        fi
    fi
done

popd
