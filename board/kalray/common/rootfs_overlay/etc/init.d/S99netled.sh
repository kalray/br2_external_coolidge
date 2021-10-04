#!/bin/bash

D="/bin/net_monitor.sh"
DN=`basename $D`

start() {
    start-stop-daemon --background --name $DN --start --quiet --exec $D
}

stop() {
    start-stop-daemon --name $DN --stop --retry 5 --quiet --name $D
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage:  {start|stop|status}"
        exit 1
        ;;
esac
exit $?
