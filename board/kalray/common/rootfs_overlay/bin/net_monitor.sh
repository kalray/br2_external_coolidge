#!/bin/bash

LEDCFG="/bin/config_netled.sh"

[ ! -f $LEDCFG ] && exit 1

ip -o monitor link | while read -r index interface status remaining; do
    iface=$(printf '%s\n' "$interface" | sed -E 's/(@.*)?:$//')
    if echo "$iface" | egrep -q enmppa ; then
        operstate=$(printf '%s\n' "$remaining" | grep -Eo ' state [^ ]+' | sed 's/^ state //')
        $LEDCFG $iface
    fi
done
