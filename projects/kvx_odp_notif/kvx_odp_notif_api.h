#ifndef __KVX_ODP_NOTIF_API__
#define __KVX_ODP_NOTIF_API__

#include "kvx_odp_notif.h"

/**
 * odpnotif_sendl() - send a mutex protected notification to the ODP cluster
 * @cid: the ODP cluster index
 * @msg: the notification message
 * @wait_ms: wait time in milliseconds for synchronous messaging
 * 		(< 0 for infinite wait)
 *
 * This function sends the notification @msg to the cluster @cid under the
 * protection of a mutex.
 * The message will be sent asynchronously if wait_ms is set to 0 and will wait
 * for an acknowledgment otherwise (wait_ms negative will wait forever).
 *
 * NOTE: Until the acknowledgment is received (even if the previous caller got
 * a timeout failure), any further notification to the same cluster will fail
 * with -EBUSY.
 * If the cluster index is out of bounds, -EINVAL is returned.
 * If the cluster index points to a cluster which has not been probed yet,
 * -EPERM is returned.
 * If a timeout is specified but the notification does not request an
 * acknowledgement or if no timeout is specified but the notification requests
 * an acknowledgement, then -EINVAL is returned.
 * In case there are no underlying buffers available, the function will
 * immediately return -ENOMEM without waiting until one becomes available.
 *
 * Returns 0 on success and an appropriate error value on failure.
 */
int odpnotif_sendl(int cid, odp_notif_t *msg, int wait_ms);

/**
 * odpnotif_send() - send a notification to the ODP cluster
 * @cid: the ODP cluster index
 * @msg: the notification message
 * @wait_ms: wait time in milliseconds for synchronous messaging
 * 		(< 0 for infinite wait)
 *
 * This function sends the notification @msg to the cluster @cid.
 * The message will be sent asynchronously if wait_ms is set to 0 and will wait
 * for an acknowledgment otherwise (wait_ms negative will wait forever).
 *
 * NOTE: Until the acknowledgment is received (even if the previous caller got
 * a timeout failure), any further notification to the same cluster will fail
 * with -EBUSY.
 * If the cluster index is out of bounds, -EINVAL is returned.
 * If the cluster index points to a cluster which has not been probed yet,
 * -EPERM is returned.
 * If a timeout is specified but the notification does not request an
 * acknowledgement or if no timeout is specified but the notification requests
 * an acknowledgement, then -EINVAL is returned.
 * In case there are no underlying buffers available, the function will
 * immediately return -ENOMEM without waiting until one becomes available.
 *
 * Returns 0 on success and an appropriate error value on failure.
 */
int odpnotif_send(int cid, odp_notif_t *msg, int wait_ms);

#endif /* __KVX_ODP_NOTIF_API__ */
