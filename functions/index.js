// /* // functions/index.js

// // This file does two things:
// // 1. Gives outfit suggestions when users ask
// // 2. Sends notifications when someone wants to swap clothes

// const functions = require("firebase-functions");
// const { onDocumentCreated } = require("firebase-functions/v2/firestore");
// const admin = require("firebase-admin");
// const express = require("express");
// const cors = require("cors");

// // Connect to Firebase
// admin.initializeApp();

// // Set up our web server
// const app = express();
// app.use(cors({ origin: true })); // Let websites talk to us
// app.use(express.json()); // Understand JSON data

// // ═══════════════════════════════════════════════════════════════
// // OUTFIT SUGGESTIONS
// // ═══════════════════════════════════════════════════════════════

// // When someone asks "what should I wear?" we answer here
// app.post("/getOutfits", (req, res) => {
//   // Get what the user sent us
//   const { images = [], category = "All" } = req.body;

//   // Mock outfit suggestions (replace with real AI later)
//   const outfits = [
//     /* your outfit data goes here */
//   ];

//   // Send suggestions back to user
//   res.status(200).json({ recommendations: outfits });
// });

// // Make this available online
// exports.api = functions.https.onRequest(app);

// // ═══════════════════════════════════════════════════════════════
// // SWAP NOTIFICATIONS
// // ═══════════════════════════════════════════════════════════════

// // When someone creates a swap request, notify the other person
// exports.onSwapRequestCreated = onDocumentCreated(
//   "swapRequests/{reqId}",
//   async (event) => {
//     // Get the swap request details
//     const data = event.data;
//     const toUid = data.toUid;

//     // Need someone to notify
//     if (!toUid) return;

//     // Find their device token for notifications
//     const userDoc = await admin.firestore().doc(`users/${toUid}`).get();
//     const token = userDoc.get("fcmToken");

//     // Can't notify without a token
//     if (!token) return;

//     // Create the notification
//     const payload = {
//       notification: {
//         title: "New Swap Request",
//         body: "Someone wants to swap clothes with you!",
//       },
//       data: {
//         requestId: event.params.reqId,
//         type: "swap_request",
//       },
//     };

//     // Send the notification
//     return admin.messaging().sendToDevice(token, payload);
//   }
// ); */
