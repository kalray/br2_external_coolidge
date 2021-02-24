// SPDX-License-Identifier: GPL-2.0
/*
 * ODP notification driver
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 2019 Kalray Inc.
 */

#define DRVNAME "kvx_odp_notif"
#define pr_fmt(fmt) DRVNAME": " fmt

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mutex.h>
#include <linux/string.h>
#include <linux/rpmsg.h>

#include "kvx_odp_notif_api.h"

struct odpnotif_cept {
	struct rpmsg_endpoint	*ept;
	struct mutex		lock;
	struct completion	completion;
	uint32_t		cluster_idx;
};

struct odpnotif_dev {
	struct odpnotif_cept epts[MAX_CLUSTERS];
};

int __init odp_notif_sysfs_init(void);
void __exit odp_notif_sysfs_exit(void);
void odp_notif_sysfs_set_ready(int cid);
void odp_notif_sysfs_set_disconnected(int cid);

#define cluster_ept_to_odpnotif_dev(ept) ((struct odpnotif_dev*) \
	((char*)(ept - cluster_idx) - offset_of(struct odpnotif_dev, epts)))

/* A different channel for each cluster */
static struct rpmsg_device_id chid_table[] = {
	{ .name	= RPMSG_NOTIF_SERVICE_NAME".0" },
	{ .name	= RPMSG_NOTIF_SERVICE_NAME".1" },
	{ .name	= RPMSG_NOTIF_SERVICE_NAME".2" },
	{ .name	= RPMSG_NOTIF_SERVICE_NAME".3" },
	{ .name	= RPMSG_NOTIF_SERVICE_NAME".4" },
	{ },
};
MODULE_DEVICE_TABLE(rpmsg, chid_table);

static int odpnotif_probe(struct rpmsg_device *rpdev);
static void odpnotif_remove(struct rpmsg_device *rpdev);
static int odpnotif_rx(struct rpmsg_device *rpdev, void *data, int len,
			void *priv, u32 src);

static struct rpmsg_driver rpmsg_ctrl_driver = {
	.drv.name	= KBUILD_MODNAME,
	.id_table	= chid_table,
	.probe		= odpnotif_probe,
	.remove		= odpnotif_remove,
	.callback	= odpnotif_rx,
};

static void *__get_notifier(void) {
	static struct odpnotif_dev odev;
	return &odev;
}

static int odpnotif_send_ept(struct odpnotif_cept *cept,
	odp_notif_t *msg, int wait_ms)
{
	int ret;
	if (wait_ms && !completion_done(&cept->completion)) {
		return -EBUSY;
	}
	ret = rpmsg_trysend(cept->ept, msg, sizeof(odp_notif_t));
	if (ret || !wait_ms)
		return ret;

	return wait_for_completion_timeout(&cept->completion,
				msecs_to_jiffies(wait_ms)) ? 0 : -ETIMEDOUT;
}

int odpnotif_sendl(int cid, odp_notif_t *msg, int wait_ms)
{
	struct odpnotif_dev *odev = (struct odpnotif_dev *)__get_notifier();
	int ret;

	if (cid < 0 || cid > MAX_CLUSTERS) return -EINVAL;
	if (wait_ms != 0 && !msg->ack_requested) return -EINVAL;
	if (odev->epts[cid].ept == NULL) return -EPERM;

	if (mutex_trylock(&odev->epts[cid].lock) == 0) {
		return -EAGAIN;
	}
	ret = odpnotif_send_ept(&odev->epts[cid], msg, wait_ms);
	mutex_unlock(&odev->epts[cid].lock);
	return ret;
}

int odpnotif_send(int cid, odp_notif_t *msg, int wait_ms)
{
	struct odpnotif_dev *odev = (struct odpnotif_dev *)__get_notifier();

	if (cid < 0 || cid > MAX_CLUSTERS) return -EINVAL;
	if (wait_ms != 0 && !msg->ack_requested) return -EINVAL;
	if (odev->epts[cid].ept == NULL) return -EPERM;

	return odpnotif_send_ept(&odev->epts[cid], msg, wait_ms);
}

static int odpnotif_rx(struct rpmsg_device *rpdev, void *data, int len,
			void *priv, u32 src)
{
	// We received a Rx notification, notify the completion
	struct odpnotif_cept *cept = (struct odpnotif_cept *)priv;
	complete(&cept->completion);
	return 0;
}

static int odpnotif_probe(struct rpmsg_device *rpdev)
{
	struct odpnotif_dev *odev;
	int cluster_idx = -1;

	dev_dbg(&rpdev->dev, "chnl %s: src(0x%x) -> dst(0x%x)\n",
		rpdev->id.name, rpdev->src, rpdev->dst);

	BUG_ON(sscanf(rpdev->id.name, RPMSG_NOTIF_SERVICE_NAME".%d",
		&cluster_idx) != 1);

	/* Make sure that the cluster id is within expected boundaries */
	BUG_ON(cluster_idx < 0);
	BUG_ON(cluster_idx >= (sizeof(odev->epts)/sizeof(odev->epts[0])));

	/* Make sure that the cluster id is was not probed already */
	odev = (struct odpnotif_dev *)__get_notifier();
	BUG_ON(odev->epts[cluster_idx].ept);

	rpdev->ept->priv = &odev->epts[cluster_idx];
	odev->epts[cluster_idx].ept = rpdev->ept;
	odev->epts[cluster_idx].cluster_idx = cluster_idx;
	mutex_init(&odev->epts[cluster_idx].lock);
	init_completion(&odev->epts[cluster_idx].completion);
	odp_notif_sysfs_set_ready(cluster_idx);

	dev_info(&rpdev->dev, "cluster[%d] notification initialized\n",
		cluster_idx);
	return 0;
}

static void odpnotif_remove(struct rpmsg_device *rpdev)
{
	struct odpnotif_cept *cept = (struct odpnotif_cept *)rpdev->ept->priv;
	odp_notif_sysfs_set_disconnected(cept->cluster_idx);
	dev_info(&rpdev->dev, "rpmsg channel client driver is removed\n");
}

static int __init odpnotif_init(void)
{
	int ret;
	struct odpnotif_dev *odev = (struct odpnotif_dev *)__get_notifier();

	memset(odev, 0, sizeof(struct odpnotif_dev));

	/* Initialize sysfs early on in case the driver is loaded by the kernel
	* because, in that case, probe is called in the register rpmsg_driver...
	*/
	ret = odp_notif_sysfs_init();
	if (ret) {
		pr_err("Sysfs init for %s failed\n", DRVNAME);
		return ret;
	}

	ret = register_rpmsg_driver(&rpmsg_ctrl_driver);
	if (!ret) {
		pr_debug("rpmsg ctrl driver registered for %s\n", DRVNAME);
	}

	return ret;
}

static void __exit odpnotif_exit(void)
{
	unregister_rpmsg_driver(&rpmsg_ctrl_driver);

	odp_notif_sysfs_exit();
}

module_init(odpnotif_init);
module_exit(odpnotif_exit);

MODULE_AUTHOR("Jean-Christophe PINCE <jcpince@kalray.eu>");
MODULE_DESCRIPTION("ODP notification driver");
MODULE_LICENSE("GPL");
