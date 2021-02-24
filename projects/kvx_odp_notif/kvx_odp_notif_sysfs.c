//#define DEBUG
#define pr_fmt(fmt)    "kvx_odp_notif.sysfs: %s -- " fmt, __func__

#include <linux/module.h>
#include <linux/device.h>
#include <linux/sysfs.h>

#include "kvx_odp_notif_api.h"

#define ODP_CLUSTER0_ID (1)
#define NB_ODP_CLUSTERS (MAX_CLUSTERS-1)
#define NB_ETH_DEVICES	(2)
#define MAX_TX_FIFO_ID  (9)

/* helpers to get the array index from the cluster id seen by the user */
#define cid2index(cid) (cid - ODP_CLUSTER0_ID)
#define cid2kobj(cid)  gnotif_sysfs.kobj_clusters_base[cid2index(cid)]

_Static_assert(NB_ODP_CLUSTERS > 0, "No ODP clusters configured");

static struct gnotif_sysfs_ {
        struct device   *sysfs_rootdev;
        struct kobject  *kobj_clusters_base[NB_ODP_CLUSTERS];
        struct kobject  *kobj_eths_base[NB_ODP_CLUSTERS][NB_ETH_DEVICES];
        odp_notif_t     notif[NB_ODP_CLUSTERS][NB_ETH_DEVICES];
        odp_notif_t     config_done_notif[NB_ODP_CLUSTERS];
        int             send_wait_ms[NB_ODP_CLUSTERS];
        int             cluster_ready[NB_ODP_CLUSTERS];
        int             use_locked_api;
	
} gnotif_sysfs;

static void cleanup_sysfs(void);

static int get_cid(const char *cluster_name) {
        int cid = -1;

        sscanf(cluster_name, "cluster%d", &cid);
        if ((cid < ODP_CLUSTER0_ID) ||
                        (cid >= (ODP_CLUSTER0_ID + NB_ODP_CLUSTERS)))
                return -1;

        return cid;
}

static int get_ethid(const char *eth_name) {
        int ethid = -1;

        sscanf(eth_name, "eth%d", &ethid);
        if ((ethid < 0) || (ethid >= NB_ETH_DEVICES))
                return -1;

        return ethid;
}

static int get_cid_ethid(struct kobject *kobj, int *cid, int *ethid) {

        if (!kobj->sd) {
                pr_err("Unable to get cid/ethid: kobj->sd is NULL\n");
                return -1;
        }
        if (!kobj->sd->parent) {
                pr_err("Unable to get cid/ethid: kobj->sd->parent is NULL\n");
                return -1;
        }
        *cid = get_cid(kobj->sd->parent->name);
        if (*cid == -1) {
                pr_err("Unable to get cid from %s\n", kobj->sd->parent->name);
                return -1;
        }
        *ethid = get_ethid(kobj->sd->name);
        if (*ethid == -1) {
                pr_err("Unable to get ethid from %s\n", kobj->sd->name);
                return -1;
        }

        return 0;
}

#define DECLARE_XXX_ATTRIBUTE(T, fmt, __nam, field, minval, maxval)     \
        static ssize_t __nam##_show(struct kobject *kobj,               \
                        struct kobj_attribute *attr, char *buf) {       \
                                                                        \
                int cid, ethid, count;                                  \
                T *ptr = NULL;                                          \
                if (get_cid_ethid(kobj, &cid, &ethid))                  \
                        return -ENXIO;                                  \
                ptr = (T *)&gnotif_sysfs.notif[cid][ethid].field;       \
                count = sprintf(buf, fmt, *ptr);                        \
                pr_debug("Read cluster[%d].eth[%d].%s: %s\n", cid,        \
                	ethid, attr->attr.name, buf);                   \
                return count;                                           \
        }                                                               \
        static ssize_t __nam##_store(struct kobject *kobj,              \
                struct kobj_attribute *attr, const char *buf,           \
                	size_t count) {                                 \
                                                                        \
                int cid, ethid;                                         \
                T new_value = minval - 1, *ptr = NULL;                  \
                if (get_cid_ethid(kobj, &cid, &ethid))                  \
                        return -ENXIO;                                  \
                ptr = (T *)&gnotif_sysfs.notif[cid][ethid].field;       \
                sscanf(buf, fmt, &new_value);                           \
                if (new_value < minval || new_value > maxval)           \
                        return -EINVAL;                                 \
                *ptr = new_value;                                       \
                pr_debug("Write cluster[%d].eth[%d].%s with %s\n", cid,   \
                	ethid, attr->attr.name, buf);                   \
                return count;                                           \
        }                                                               \
        static struct kobj_attribute __nam##_attr = __ATTR_RW(__nam);

#define DECLARE_INT_ATTRIBUTE(__nam, field, minval, maxval) \
        DECLARE_XXX_ATTRIBUTE(int, "%d", __nam, field, minval, maxval)
#define DECLARE_LONG_ATTRIBUTE(__nam, field, minval, maxval) \
        DECLARE_XXX_ATTRIBUTE(long, "%ld", __nam, field, minval, maxval)
#define DECLARE_UINT64_ATTRIBUTE(__nam, field, minval, maxval) \
        DECLARE_XXX_ATTRIBUTE(uint64_t, "%llx", __nam, field, minval, maxval)
#define DECLARE_UINT8_ATTRIBUTE(__nam, field, minval, maxval) \
        DECLARE_XXX_ATTRIBUTE(uint8_t, "%hhu", __nam, field, minval, maxval)
#define DECLARE_UINT16_ATTRIBUTE(__nam, field, minval, maxval) \
        DECLARE_XXX_ATTRIBUTE(uint16_t, "%hu", __nam, field, minval, maxval)
#define DECLARE_BOOL_ATTRIBUTE(__nam, field) \
        DECLARE_XXX_ATTRIBUTE(uint8_t, "%hhu", __nam, field, 0, 1)

DECLARE_UINT8_ATTRIBUTE(type, type, ENOTIF_PARSER_INFO, ENOTIF_LAST_ENUM)
DECLARE_BOOL_ATTRIBUTE(ack_requested, ack_requested)
DECLARE_UINT8_ATTRIBUTE(parser_id, parser_offload.parser_id, 0, KVX_ETH_PARSERS_COUNT-1)
DECLARE_UINT8_ATTRIBUTE(parser_rule_id, parser_offload.rule_id, 0, KVX_ETH_PARSER_RULES_COUNT-1)
DECLARE_UINT8_ATTRIBUTE(parser_rule_type, parser_offload.rule.type, 0, KVX_ETH_PARSER_RULE_TYPE_MAX)
DECLARE_UINT8_ATTRIBUTE(parser_rule_add_metadata_index, parser_offload.rule.add_metadata_index, 0, 1)
DECLARE_UINT8_ATTRIBUTE(parser_rule_check_header_checksum, parser_offload.rule.check_header_checksum, 0, 1)

DECLARE_UINT8_ATTRIBUTE(tx_fifo_id, tx_config.fifo_id, 0, MAX_TX_FIFO_ID)
DECLARE_BOOL_ATTRIBUTE(tx_header_enabled, tx_config.header_enabled)
DECLARE_UINT16_ATTRIBUTE(tx_asn, tx_config.asn, 0, (uint16_t)~0)

DECLARE_UINT64_ATTRIBUTE(rx_ids_small, rx_config.bitfield_id_small, 0, ~0ULL)
DECLARE_UINT16_ATTRIBUTE(rx_asn, rx_config.asn, 0, (uint16_t)~0)
DECLARE_UINT16_ATTRIBUTE(rx_split_trigger, rx_config.split_trigger, 0, (uint16_t)~0)

DECLARE_BOOL_ATTRIBUTE(link_status, link_status)
DECLARE_INT_ATTRIBUTE(mtu, mtu, 0, (uint16_t)~0)
DECLARE_BOOL_ATTRIBUTE(available, value)

static ssize_t config_done_show(struct kobject *kobj,
                struct kobj_attribute *attr, char *buf) {
        int cid;
        if (!kobj->sd) {
                pr_err("Unable to get cid: kobj->sd is NULL\n");
                return -ENXIO;
        }
        cid = get_cid(kobj->sd->name);
        if (cid == -1) {
                pr_err("Unable to get cid from %s\n", kobj->sd->name);
                return -ENXIO;
        }

        pr_debug("Read cluster[%d].%s: %s\n", cid, attr->attr.name, buf);
        return sprintf(buf, "%d", gnotif_sysfs.config_done_notif[cid].value);
}

static ssize_t config_done_store(struct kobject *kobj,
                struct kobj_attribute *attr,const char *buf, size_t count) {
        int cid, ret;
        if (!kobj->sd) {
                pr_err("Unable to get cid: kobj->sd is NULL\n");
                return -ENXIO;
        }
        cid = get_cid(kobj->sd->name);
        if (cid == -1) {
                pr_err("Unable to get cid from %s\n", kobj->sd->name);
                return -ENXIO;
        }

        sscanf(buf, "%d", &ret);
        gnotif_sysfs.config_done_notif[cid].value = ret ? 1 : 0;

        pr_debug("Set cluster[%d].%s to %d\n", cid,
                attr->attr.name, gnotif_sysfs.config_done_notif[cid].value);

        gnotif_sysfs.config_done_notif[cid].type = ENOTIF_ETH_CONFIG_DONE;
        if (gnotif_sysfs.use_locked_api)
                ret = odpnotif_sendl(cid, &gnotif_sysfs.config_done_notif[cid],
                        gnotif_sysfs.send_wait_ms[cid]);
        else
                ret = odpnotif_send(cid, &gnotif_sysfs.config_done_notif[cid],
                        gnotif_sysfs.send_wait_ms[cid]);
        if (ret < 0) {
                pr_err("Failed to send cluster[%d].%s(%d), error %d\n", cid,
                        attr->attr.name,
                        gnotif_sysfs.config_done_notif[cid].value, ret);
		return ret;
	}
		pr_info("cluster[%d] config done (%d)\n", cid,
				gnotif_sysfs.config_done_notif[cid].value);
        return count;
}

static struct kobj_attribute config_done_attr = __ATTR_RW(config_done);

static ssize_t mac_address_show(struct kobject *kobj,
                struct kobj_attribute *attr, char *buf) {
        int cid, ethid;
        if (get_cid_ethid(kobj, &cid, &ethid))
                return -ENXIO;

        pr_debug("Read cluster[%d].eth[%d].%s: %s\n", cid, ethid,
                attr->attr.name, buf);
        return sprintf(buf, "%02x:%02x:%02x:%02x:%02x:%02x",
                gnotif_sysfs.notif[cid][ethid].mac_address[0],
                gnotif_sysfs.notif[cid][ethid].mac_address[1],
                gnotif_sysfs.notif[cid][ethid].mac_address[2],
                gnotif_sysfs.notif[cid][ethid].mac_address[3],
                gnotif_sysfs.notif[cid][ethid].mac_address[4],
                gnotif_sysfs.notif[cid][ethid].mac_address[5]
                );
}

static ssize_t mac_address_store(struct kobject *kobj,
                struct kobj_attribute *attr,const char *buf, size_t count) {

        int cid, ethid, m0, m1, m2, m3, m4, m5, ret;
        if (get_cid_ethid(kobj, &cid, &ethid))
                return -ENXIO;

        ret = sscanf(buf, "%x:%x:%x:%x:%x:%x", &m0, &m1, &m2, &m3, &m4, &m5);
        if (ret != 6) {
                pr_err("Unable to parse the mac address from %s\n", buf);
                return -EINVAL;
        }
        gnotif_sysfs.notif[cid][ethid].mac_address[0] = m0 & 0xff;
        gnotif_sysfs.notif[cid][ethid].mac_address[1] = m1 & 0xff;
        gnotif_sysfs.notif[cid][ethid].mac_address[2] = m2 & 0xff;
        gnotif_sysfs.notif[cid][ethid].mac_address[3] = m3 & 0xff;
        gnotif_sysfs.notif[cid][ethid].mac_address[4] = m4 & 0xff;
        gnotif_sysfs.notif[cid][ethid].mac_address[5] = m5 & 0xff;

        pr_debug("Set cluster[%d].eth[%d].mac_address to %02x:%02x:%02x:%02x:%02x:%02x\n",
                cid, ethid, m0, m1, m2, m3, m4, m5);
        return count;
}
static struct kobj_attribute mac_address_attr = __ATTR_RW(mac_address);

static ssize_t extra_payload_wa_show(struct kobject *kobj,
                struct kobj_attribute *attr, char *buf) {
        int cid, ethid;
		
        if (get_cid_ethid(kobj, &cid, &ethid))
			return -ENXIO;

		return sprintf(buf, "%d", gnotif_sysfs.notif[cid][ethid].extra_payload_wa);
}

static ssize_t extra_payload_wa_store(struct kobject *kobj,
                struct kobj_attribute *attr,const char *buf, size_t count) {

	int cid, ethid, extra_payload_wa, ret;
	if (get_cid_ethid(kobj, &cid, &ethid))
		return -ENXIO;
	
	ret = sscanf(buf, "%d", &extra_payload_wa);

	gnotif_sysfs.notif[cid][ethid].extra_payload_wa = extra_payload_wa;

	return count;
}
static struct kobj_attribute extra_payload_wa_attr = __ATTR_RW(extra_payload_wa);


static ssize_t send_wait_ms_show(struct kobject *kobj,
                struct kobj_attribute *attr, char *buf) {
        int cid, ethid;
        if (get_cid_ethid(kobj, &cid, &ethid))
                return -ENXIO;

        pr_debug("Read cluster[%d].eth[%d].%s: %s\n", cid, ethid, attr->attr.name,
                buf);
        return sprintf(buf, "%d", gnotif_sysfs.send_wait_ms[cid]);
}

static ssize_t send_wait_ms_store(struct kobject *kobj,
                struct kobj_attribute *attr,const char *buf, size_t count) {
        int cid, ethid, value;
        if (get_cid_ethid(kobj, &cid, &ethid))
                return -ENXIO;

        sscanf(buf,"%d",&value);
        if (value < 0)
                return -EINVAL;
        gnotif_sysfs.send_wait_ms[cid] = value;

        pr_debug("Set cluster[%d].eth[%d].%s to %dms\n", cid, ethid,
                attr->attr.name, gnotif_sysfs.send_wait_ms[cid]);
        return count;
}

static struct kobj_attribute send_wait_ms_attr = __ATTR_RW(send_wait_ms);

static ssize_t use_locked_api_show(struct kobject *kobj,
                struct kobj_attribute *attr, char *buf) {

        pr_debug("Read %s: %s\n", attr->attr.name, buf);
        return sprintf(buf, "%d", gnotif_sysfs.use_locked_api);
}

static ssize_t use_locked_api_store(struct kobject *kobj,
                struct kobj_attribute *attr,const char *buf, size_t count) {
        int  value;

        sscanf(buf,"%d",&value);
        if (value < 0)
                return -EINVAL;
        gnotif_sysfs.use_locked_api = value ? 1 : 0;

        pr_debug("Set %s to %d\n", attr->attr.name,
                gnotif_sysfs.use_locked_api);
        return count;
}

static struct kobj_attribute use_locked_api_attr = __ATTR_RW(use_locked_api);

static ssize_t cluster_ready_show(struct kobject *kobj,
                struct kobj_attribute *attr, char *buf) {

        int cid;
        if (!kobj->sd) {
                pr_err("Unable to get cid: kobj->sd is NULL\n");
                return -ENXIO;
        }
        cid = get_cid(kobj->sd->name);
        if (cid == -1) {
                pr_err("Unable to get cid from %s\n", kobj->sd->name);
                return -ENXIO;
        }
        pr_debug("Read %s: %s\n", attr->attr.name, buf);
        return sprintf(buf, "%d", gnotif_sysfs.cluster_ready[cid]);
}

static struct kobj_attribute cluster_ready_attr = __ATTR_RO(cluster_ready);

static ssize_t send_notif_store(struct kobject *kobj,
                struct kobj_attribute *attr,const char *buf, size_t count) {

        int cid, ethid, ret;
        if (get_cid_ethid(kobj, &cid, &ethid))
                return -ENXIO;

        pr_debug("Send notification to cluster[%d]\n", cid);

        if (gnotif_sysfs.use_locked_api)
                ret = odpnotif_sendl(cid, &gnotif_sysfs.notif[cid][ethid],
                        gnotif_sysfs.send_wait_ms[cid]);
        else
                ret = odpnotif_send(cid, &gnotif_sysfs.notif[cid][ethid],
                        gnotif_sysfs.send_wait_ms[cid]);
        if (ret < 0) {
                pr_err("Failed to send cluster[%d] notification, error %d\n",
			cid, ret);
		return ret;
	}
        return count;
}

static struct kobj_attribute send_notif_attr = __ATTR_WO(send_notif);

#define CREATE_ETH_ENTRY(cid, ethid, name)                              \
        if(sysfs_create_file(kobj_eth, & name##_attr.attr)) {           \
                pr_err("Cannot create sysfs file in cluster%d/eth%d/%s\n", \
                        cid, ethid, #name);                             \
                return -1;                                              \
        }                                                               \

static int create_ethid_tree(int cid, int ethid) {

        char name[16];
        struct kobject *kobj_eth;

        snprintf(name, sizeof(name), "eth%d", ethid);
        kobj_eth = kobject_create_and_add(name,
                cid2kobj(cid));

        if (!kobj_eth) return -1;

        gnotif_sysfs.kobj_eths_base[cid2index(cid)][ethid] = kobj_eth;
        gnotif_sysfs.notif[cid][ethid].eth_id = ethid;

        CREATE_ETH_ENTRY(cid, ethid, type);
        CREATE_ETH_ENTRY(cid, ethid, parser_id);
        CREATE_ETH_ENTRY(cid, ethid, parser_rule_id);
        CREATE_ETH_ENTRY(cid, ethid, parser_rule_type);
        CREATE_ETH_ENTRY(cid, ethid, parser_rule_add_metadata_index);
        CREATE_ETH_ENTRY(cid, ethid, parser_rule_check_header_checksum);
        CREATE_ETH_ENTRY(cid, ethid, ack_requested);
        CREATE_ETH_ENTRY(cid, ethid, tx_fifo_id);
        CREATE_ETH_ENTRY(cid, ethid, tx_header_enabled);
        CREATE_ETH_ENTRY(cid, ethid, tx_asn);
        CREATE_ETH_ENTRY(cid, ethid, rx_ids_small);
        CREATE_ETH_ENTRY(cid, ethid, rx_asn);
        CREATE_ETH_ENTRY(cid, ethid, rx_split_trigger);
        CREATE_ETH_ENTRY(cid, ethid, link_status);
        CREATE_ETH_ENTRY(cid, ethid, mtu);
        CREATE_ETH_ENTRY(cid, ethid, mac_address);
		CREATE_ETH_ENTRY(cid, ethid, extra_payload_wa);
        CREATE_ETH_ENTRY(cid, ethid, available);
        CREATE_ETH_ENTRY(cid, ethid, send_wait_ms);
        CREATE_ETH_ENTRY(cid, ethid, send_notif);

        return 0;
}

static int create_clusterid_tree(int cid) {

        char name[16];
        int ethid;

        snprintf(name, sizeof(name), "cluster%d", cid);
        cid2kobj(cid) =
        kobject_create_and_add(name, &gnotif_sysfs.sysfs_rootdev->kobj);

        if (!cid2kobj(cid)) return -1;

        for (ethid = 0 ; ethid < NB_ETH_DEVICES ; ethid++)
        if (create_ethid_tree(cid, ethid)) return -1;

        if(sysfs_create_file(cid2kobj(cid), &config_done_attr.attr)) {
                pr_err("Cannot create sysfs file in cluster%d/config_done\n",
                        cid);
                return -1;
        }

        if(sysfs_create_file(cid2kobj(cid), &use_locked_api_attr.attr)) {
                pr_err("Cannot create sysfs file in use_locked_api\n");
                cleanup_sysfs();
                return -1;
        }

        if(sysfs_create_file(cid2kobj(cid), &cluster_ready_attr.attr)) {
                pr_err("Cannot create sysfs file in cluster_ready_attr\n");
                cleanup_sysfs();
                return -1;
        }

        return 0;
}

static void cleanup_sysfs(void) {
        int cid, ethid;
        if (!gnotif_sysfs.sysfs_rootdev) return;

        for (cid = ODP_CLUSTER0_ID ;
                cid < ODP_CLUSTER0_ID + NB_ODP_CLUSTERS; cid++) {

                for (ethid = 0 ; ethid < NB_ETH_DEVICES ; ethid++) {
                        struct kobject *kobj_eth =
                                gnotif_sysfs.kobj_eths_base[cid2index(cid)]
                                        [ethid];
                        if (!kobj_eth) continue;

                        sysfs_remove_file(kobj_eth, &type_attr.attr);
                        sysfs_remove_file(kobj_eth, &parser_id_attr.attr);
                        sysfs_remove_file(kobj_eth, &parser_rule_id_attr.attr);
                        sysfs_remove_file(kobj_eth, &parser_rule_type_attr.attr);
                        sysfs_remove_file(kobj_eth, &parser_rule_add_metadata_index_attr.attr);
                        sysfs_remove_file(kobj_eth, &parser_rule_check_header_checksum_attr.attr);
                        sysfs_remove_file(kobj_eth, &ack_requested_attr.attr);
                        sysfs_remove_file(kobj_eth, &tx_fifo_id_attr.attr);
                        sysfs_remove_file(kobj_eth,
                                &tx_header_enabled_attr.attr);
                        sysfs_remove_file(kobj_eth, &tx_asn_attr.attr);
                        sysfs_remove_file(kobj_eth, &rx_ids_small_attr.attr);
                        sysfs_remove_file(kobj_eth, &rx_asn_attr.attr);
                        sysfs_remove_file(kobj_eth,
                                &rx_split_trigger_attr.attr);
                        sysfs_remove_file(kobj_eth, &link_status_attr.attr);
                        sysfs_remove_file(kobj_eth, &mtu_attr.attr);
                        sysfs_remove_file(kobj_eth, &mac_address_attr.attr);
						sysfs_remove_file(kobj_eth, &extra_payload_wa_attr.attr);
                        sysfs_remove_file(kobj_eth, &available_attr.attr);
                        sysfs_remove_file(kobj_eth, &send_wait_ms_attr.attr);
                        sysfs_remove_file(kobj_eth, &send_notif_attr.attr);

                        kobject_put(kobj_eth);
                }
                if (cid2kobj(cid)) {
                        sysfs_remove_file( cid2kobj(cid),
                                &config_done_attr.attr);
                        kobject_put(cid2kobj(cid));
                }
        }
        sysfs_remove_file(&gnotif_sysfs.sysfs_rootdev->kobj,
                &use_locked_api_attr.attr);
        sysfs_remove_file(&gnotif_sysfs.sysfs_rootdev->kobj,
                &cluster_ready_attr.attr);
        root_device_unregister(gnotif_sysfs.sysfs_rootdev);
}

void odp_notif_sysfs_set_ready(int cid) {
        /* Should really never happen but better safe than sorry! */
        BUG_ON(cid < 1 || cid >= MAX_CLUSTERS);
        gnotif_sysfs.cluster_ready[cid] = true;
}

void odp_notif_sysfs_set_disconnected(int cid) {
        BUG_ON(cid < 1 || cid >= MAX_CLUSTERS);
        gnotif_sysfs.cluster_ready[cid] = false;
}

int __init odp_notif_sysfs_init(void) {
        int cid;
        memset(&gnotif_sysfs, 0 , sizeof(gnotif_sysfs));

        /*Creating struct class*/
        if ((gnotif_sysfs.sysfs_rootdev = root_device_register("odp_notif")) ==
                NULL) {
                pr_err("Cannot create the root device\n");
                return -1;
        }

        /*Creating a directory in /sys/devices/ */
        for (cid = ODP_CLUSTER0_ID ; cid < ODP_CLUSTER0_ID + NB_ODP_CLUSTERS ;
                cid++)
                if (create_clusterid_tree(cid)) {
                        cleanup_sysfs();
                        return -1;
                }

        pr_debug("init done!!!\n");
        return 0;
}

void __exit odp_notif_sysfs_exit(void) {
        cleanup_sysfs();
        pr_debug("exit done!!!\n");
}
