#ifndef __KVX_ODP_NOTIF__
#define __KVX_ODP_NOTIF__

#define RPMSG_NOTIF_SERVICE_NAME	"kvx-odp-notif"
#define MAX_CLUSTERS			(5)
#define RPMSG_SRC_ADDR_ODP_NOTIF	(1)
#define KVX_ETH_COUNT			(2)
#define KVX_ETH_PARSERS_COUNT		(32)
#define KVX_ETH_PARSER_RULES_COUNT	(10)
#define MAC_ADDRESS_SIZE		(6)

enum parser_ptype {
	PTYPE_END_OF_RULE = 0x0,
	PTYPE_MAC_VLAN    = 0x01,
	PTYPE_IP_V4       = 0x03,
	PTYPE_IP_V6       = 0x04,
	PTYPE_VXLAN       = 0x07,
	PTYPE_UDP         = 0x08,
	PTYPE_TCP         = 0x09,
	PTYPE_MPLS        = 0x0A,
	PTYPE_ROCE        = 0x0B,
	// extra ptypes, hw ptype does not distinguish v1 and v2
	PTYPE_ROCEV1      = 0x0C,
	PTYPE_ROCEV2      = 0x0D,
	PTYPE_SKIP        = 0x1E,
	PTYPE_CUSTOM      = 0x1F,
	KVX_ETH_PARSER_RULE_TYPE_MAX = PTYPE_CUSTOM,
};


static const char __attribute__((unused)) *csumstr[] = {
			"CSUM_IPV4", "CSUM_TCP", "CSUM_UDP", "CSUM_ROCE"};
static const char __attribute__((unused)) *protostr[] = {
			"PROTO_IPV4", "PROTO_TCP", "PROTO_UDP", "PROTO_ROCE", "PROTO_ROCE_V2"};
static const char __attribute__((unused)) *linkstr[] = {"LINK DOWN", "LINK UP"};

#define csum2str(csum) (csum <= ENOTIF_CSUM_LAST ? csumstr[csum] : "CSUM_UNKNOWN")
#define proto2str(proto) (proto <= ENOTIF_PROTO_LAST ? protostr[proto] : "PROTO_UNKNOWN")
#define linkstatus2str(ls) (ls <= ENOTIF_LINK_LAST ? linkstr[ls] : "LINK UNKNOWN")

typedef enum __attribute__ ((packed)) {
	ENOTIF_PARSER_INFO = 0,
	ENOTIF_RX_CONFIG,
	ENOTIF_TX_CONFIG,
	ENOTIF_MTU,
	ENOTIF_LINK_STATUS,
	ENOTIF_ETH_AVAILABLE,
	ENOTIF_ETH_CONFIG_DONE,
	ENOTIF_MAC,
	ENOTIF_EXTRA_PAYLOAD_WA,
	ENOTIF_LAST_ENUM = ENOTIF_EXTRA_PAYLOAD_WA
} enotif_type_t;

typedef enum __attribute__ ((packed)) {
	ENOTIF_LINK_DOWN = 0,
	ENOTIF_LINK_UP,
	ENOTIF_LINK_LAST = ENOTIF_LINK_UP
} enotif_link_status_t;

typedef struct __attribute__ ((packed)) {
	uint8_t type;
	uint8_t add_metadata_index;
	uint8_t check_header_checksum;
} notif_parser_rule_t;
typedef struct __attribute__ ((packed)) {
	uint8_t parser_id;
	uint8_t rule_id;
	notif_parser_rule_t rule;
} notif_parser_offload_t;

typedef struct __attribute__ ((packed)) {
	uint64_t bitfield_id_small;
	uint16_t asn;
	uint16_t split_trigger;
} notif_rx_config_t;

typedef struct __attribute__ ((packed)) {
	uint8_t		fifo_id;
	uint8_t		header_enabled;
	uint16_t	asn;
} notif_tx_config_t;

typedef struct __attribute__ ((packed)) {
	uint8_t 	type;
	bool 		ack_requested;
	uint8_t 	eth_id;
	union {
		notif_parser_offload_t	parser_offload;
		notif_tx_config_t	tx_config;
		notif_rx_config_t	rx_config;
		enotif_link_status_t 	link_status;
		uint16_t		mtu;
		uint8_t			mac_address[MAC_ADDRESS_SIZE];
		uint8_t			extra_payload_wa;
		uint8_t			value;
	} __attribute__ ((aligned (8)));
} odp_notif_t;

#endif /* __KVX_ODP_NOTIF__ */
