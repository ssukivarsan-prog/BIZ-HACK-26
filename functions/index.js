/**
 * FreshVeg - Firebase Cloud Functions
 *
 * Deploy with:
 *   cd functions
 *   npm install
 *   firebase deploy --only functions
 *
 * Requires Node.js 18+
 */

const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

// ─── Notify vendor when a new order is placed ─────────────────────────────────
exports.onNewOrder = onDocumentCreated("orders/{orderId}", async (event) => {
  const order = event.data.data();
  const orderId = event.params.orderId;

  logger.info(`New order placed: ${orderId} by ${order.customerName}`);

  try {
    // Get all vendor FCM tokens
    const vendorsSnap = await db
      .collection("users")
      .where("role", "==", "vendor")
      .get();

    const tokens = vendorsSnap.docs
      .map((doc) => doc.data().fcmToken)
      .filter(Boolean);

    if (tokens.length === 0) {
      logger.info("No vendor tokens found");
      return null;
    }

    const message = {
      tokens,
      notification: {
        title: "🛒 New Order Received!",
        body: `${order.customerName} ordered ₹${Math.round(order.totalAmount)}`,
      },
      data: {
        orderId,
        type: "new_order",
        customerName: order.customerName,
        totalAmount: String(order.totalAmount),
      },
      android: {
        notification: {
          channelId: "freshveg_orders",
          color: "#2E7D32",
          priority: "high",
          sound: "default",
        },
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            contentAvailable: true,
          },
        },
      },
    };

    const response = await messaging.sendEachForMulticast(message);
    logger.info(
      `Sent new-order notification: ${response.successCount} success, ${response.failureCount} failed`
    );

    // Clean up invalid tokens
    response.responses.forEach((resp, idx) => {
      if (
        !resp.success &&
        (resp.error?.code === "messaging/invalid-registration-token" ||
          resp.error?.code === "messaging/registration-token-not-registered")
      ) {
        const invalidToken = tokens[idx];
        logger.warn(`Removing invalid token: ${invalidToken}`);
        vendorsSnap.docs[idx].ref.update({ fcmToken: null }).catch(logger.error);
      }
    });

    return response;
  } catch (error) {
    logger.error("Error sending new-order notification:", error);
    return null;
  }
});

// ─── Notify customer when order status changes ────────────────────────────────
exports.onOrderStatusChange = onDocumentUpdated("orders/{orderId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const orderId = event.params.orderId;

  // Only proceed if status actually changed
  if (before.status === after.status) return null;

  logger.info(`Order ${orderId} status: ${before.status} → ${after.status}`);

  const statusMessages = {
    confirmed: {
      title: "✅ Order Confirmed!",
      body: "Your order has been confirmed by the vendor.",
    },
    preparing: {
      title: "👨‍🍳 Preparing Your Order",
      body: "Your fresh vegetables are being packed right now.",
    },
    out_for_delivery: {
      title: "🚚 Out for Delivery!",
      body: "Your order is on its way to you.",
    },
    delivered: {
      title: "🎉 Order Delivered!",
      body: "Your fresh vegetables have arrived. Enjoy!",
    },
    cancelled: {
      title: "❌ Order Cancelled",
      body: "Your order has been cancelled. Contact the vendor for details.",
    },
  };

  const msg = statusMessages[after.status];
  if (!msg) return null;

  try {
    // Get customer FCM token
    const customerDoc = await db.collection("users").doc(after.customerId).get();
    const fcmToken = customerDoc.data()?.fcmToken;

    if (!fcmToken) {
      logger.info(`No FCM token for customer ${after.customerId}`);
      return null;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: msg.title,
        body: msg.body,
      },
      data: {
        orderId,
        type: "order_status_update",
        status: after.status,
        customerName: after.customerName,
      },
      android: {
        notification: {
          channelId: "freshveg_orders",
          color: "#2E7D32",
          priority: "high",
          sound: "default",
        },
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await messaging.send(message);
    logger.info(`Status notification sent: ${response}`);
    return response;
  } catch (error) {
    logger.error("Error sending status notification:", error);
    return null;
  }
});

// ─── Daily inventory reset (scheduled — runs every day at 5:00 AM IST) ────────
exports.scheduledInventoryReset = require("firebase-functions/v2/scheduler")
  .onSchedule(
    {
      schedule: "0 5 * * *",       // 5:00 AM UTC (10:30 AM IST)
      timeZone: "Asia/Kolkata",
      retryCount: 1,
    },
    async () => {
      logger.info("Running scheduled inventory reset");
      const batch = db.batch();
      const vegsSnap = await db.collection("vegetables").get();

      vegsSnap.docs.forEach((doc) => {
        batch.update(doc.ref, {
          isAvailable: true,
          updatedAt: new Date(),
        });
      });

      await batch.commit();
      logger.info(`Reset ${vegsSnap.size} vegetables to available`);
    }
  );
