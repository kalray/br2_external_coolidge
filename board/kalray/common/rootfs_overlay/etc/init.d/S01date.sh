#!/bin/sh

start() {
	date -s '2019-01-01 00:00:00'
	return 0
}

case "$1" in
	start)
		start;;
	stop)
		:;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
esac
