// lib/notifications/notification_triggers.dart
//
// This file documents the Cloud Functions you should deploy alongside the app.
// Create a `functions/index.js` in your Firebase project with this logic.
//
// Deploy with: firebase deploy --only functions
//
// ─────────────────────────────────────────────────────────────────────────────
// functions/index.js
// ─────────────────────────────────────────────────────────────────────────────
//
// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();
//
// // Trigger: when an order's status changes
// exports.onOrderStatusChange = functions.firestore
//   .document("orders/{orderId}")
//   .onUpdate(async (change, context) => {
//     const before = change.before.data();
//     const after = change.after.data();
//
//     if (before.status === after.status) return null;
//
//     // Get customer FCM token
//     const customerDoc = await admin
//       .firestore()
//       .collection("users")
//       .doc(after.customerId)
//       .get();
//
//     const fcmToken = customerDoc.data()?.fcmToken;
//     if (!fcmToken) return null;
//
//     const statusMessages = {
//       confirmed: { title: "Order Confirmed! ✅", body: "Your order has been confirmed by the vendor." },
//       preparing: { title: "Order Being Prepared 👨‍🍳", body: "Your fresh vegetables are being packed." },
//       out_for_delivery: { title: "Out for Delivery 🚚", body: "Your order is on the way!" },
//       delivered: { title: "Order Delivered! 🎉", body: "Enjoy your fresh vegetables!" },
//       cancelled: { title: "Order Cancelled ❌", body: "Your order has been cancelled." },
//     };
//
//     const msg = statusMessages[after.status];
//     if (!msg) return null;
//
//     const message = {
//       token: fcmToken,
//       notification: { title: msg.title, body: msg.body },
//       data: { orderId: context.params.orderId, status: after.status },
//       android: {
//         notification: {
//           channelId: "freshveg_orders",
//           color: "#2E7D32",
//           clickAction: "FLUTTER_NOTIFICATION_CLICK",
//         },
//       },
//       apns: {
//         payload: { aps: { sound: "default", badge: 1 } },
//       },
//     };
//
//     return admin.messaging().send(message);
//   });
//
// // Trigger: notify vendor when new order is placed
// exports.onNewOrder = functions.firestore
//   .document("orders/{orderId}")
//   .onCreate(async (snap, context) => {
//     const order = snap.data();
//
//     // Get all vendor tokens
//     const vendorsSnap = await admin
//       .firestore()
//       .collection("users")
//       .where("role", "==", "vendor")
//       .get();
//
//     const tokens = vendorsSnap.docs
//       .map((d) => d.data().fcmToken)
//       .filter(Boolean);
//
//     if (tokens.length === 0) return null;
//
//     const message = {
//       tokens,
//       notification: {
//         title: "New Order Received! 🛒",
//         body: `${order.customerName} placed an order for ₹${order.totalAmount.toFixed(0)}`,
//       },
//       data: { orderId: context.params.orderId, type: "new_order" },
//     };
//
//     return admin.messaging().sendEachForMulticast(message);
//   });
//
// ─────────────────────────────────────────────────────────────────────────────
// In-App notification trigger (Dart side) - calls after order status update
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import 'notification_service.dart';

/// Shows a local notification after the vendor updates an order status.
/// Cloud Functions handles push to customers; this is for in-app feedback.
Future<void> showOrderUpdateNotification(
  WidgetRef ref,
  OrderStatus newStatus,
) async {
  final svc = ref.read(notificationServiceProvider);
  final msgs = {
    OrderStatus.confirmed: ('Order Confirmed ✅', 'The order has been confirmed.'),
    OrderStatus.preparing: ('Preparing Order 👨‍🍳', 'The vendor is packing your order.'),
    OrderStatus.outForDelivery: ('Out for Delivery 🚚', 'Your order is on the way!'),
    OrderStatus.delivered: ('Order Delivered 🎉', 'The customer received their order.'),
    OrderStatus.cancelled: ('Order Cancelled ❌', 'The order has been cancelled.'),
  };
  final msg = msgs[newStatus];
  if (msg != null) {
    await svc.showLocalNotification(title: msg.$1, body: msg.$2);
  }
}
