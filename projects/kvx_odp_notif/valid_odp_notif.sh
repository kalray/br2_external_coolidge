#!/usr/bin/env bash
#
# Start the ODP notification validation suite
#

set -eu

source /valid/valid-helpers.sh

function __hash() {
	local val=$1
	local mod=$2
	echo $(( $(cksum <<< "$val" | cut -f1 -d' ') % "$mod" ))
}

modprobe -r kvx_odp_notif
# Required only on ISS
modprobe kvx_odp_notif

# Align CID with the MPPA_COS_MASTER_CC flag used to link the COS app
CID=2
FW="odp_notif"
WAIT_READY_TIMEOUT_S=20
ODP_NOTIF_ETHID=0
ONSYS="/sys/devices/odp_notif/cluster${CID}/eth${ODP_NOTIF_ETHID}"

# start_remote_cluster exits on failure
start_remote_cluster ${CID} ${FW}
cd ${ONSYS}

# Wait for the COS app to be ready...
while true; do
	ready=$(cat ../cluster_ready)
	echo "cluster_ready is ${ready}"
	if [ "${ready}" -eq "1" ]; then
		break
	fi
	if [ $((WAIT_READY_TIMEOUT_S--)) -eq 0 ]; then
		echo "Timeout waiting for the remote cluster to be ready!!!"
		stop_remote_cluster ${CID}
		exit 1
	fi
	sleep 1
done

# Sets the configuration done flag to allow the remote to get the settings back during our tests
echo 1 > ../config_done
sleep 0.5

new_test "Sends configs notification"

echo 0 > type
for parser_id in 0 1 2 7 12 31; do
	echo "$parser_id" > parser_id
	for rule_id in $(seq 0 "$(__hash $parser_id 8)" ); do
		echo "$rule_id" > parser_rule_id
		# reproducable random values
		echo "$(__hash $((parser_id+rule_id)) 0x1f )" > parser_rule_type
		echo "$(__hash $((parser_id+rule_id)) 2 )" > parser_rule_add_metadata_index
		echo "$(__hash $((parser_id+rule_id)) 2 )" > parser_rule_check_header_checksum
		echo 1 > send_notif
	done
done

echo 2 > type
echo 5 > tx_asn
echo 6 > tx_fifo_id
echo 1 > tx_header_enabled
echo 1 > send_notif

echo 1 > type
echo 128 > rx_split_trigger
echo 0x11 > rx_ids_small
echo 15 > rx_asn
echo 1 > send_notif

echo 1 > ../../cluster3/eth0/send_notif || \
	echo "Failed to send cluster3 notification"

echo 3 > type
echo 1500 > mtu
echo 1 > send_notif

echo 4 > type
echo 0 > link_status
echo 1 > send_notif

echo 4 > type
echo 1 > link_status
echo 1 > ack_requested
echo 1 > send_notif
echo 0 > ack_requested

echo 5 > type
echo 1 > available
echo 1 > send_notif

cd ../eth1

echo 0 > type
for parser_id in 0 5; do
	echo "$parser_id" > parser_id
	for rule_id in $(seq 0 "$(__hash $parser_id 8)" ); do
		echo "$rule_id" > parser_rule_id
		# reproducable random values
		echo "$(__hash $((parser_id+rule_id)) 0x1f )" > parser_rule_type
		echo "$(__hash $((parser_id+rule_id)) 2 )" > parser_rule_add_metadata_index
		echo "$(__hash $((parser_id+rule_id)) 2 )" > parser_rule_check_header_checksum
		echo 1 > send_notif
	done
done

echo 5 > type
echo 1 > available
echo 1 > send_notif

echo 1 > ../config_done

echo "odp_notif test script succeded"

# Stop the remote cluster
wait_remote_cluster ${CID}
modprobe -r kvx_odp_notif
