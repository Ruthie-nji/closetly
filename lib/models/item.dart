// lib/models/item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SwapRequest {
  final String fromUid;
  final String offeredItemId;
  final String status; // "pending", "accepted", "rejected"
  final Timestamp at;

  SwapRequest({
    required this.fromUid,
    required this.offeredItemId,
    required this.status,
    required this.at,
  });

  factory SwapRequest.fromMap(Map<String, dynamic> m) => SwapRequest(
    fromUid: m['from'] as String,
    offeredItemId: m['offeredItemId'] as String,
    status: m['status'] as String,
    at: m['at'] as Timestamp,
  );

  Map<String, dynamic> toMap() => {
    'from': fromUid,
    'offeredItemId': offeredItemId,
    'status': status,
    'at': at,
  };
}

class Item {
  final String id;
  final String name;
  final String photoURL;
  // … other fields you have on your item …
  final SwapRequest? swapRequest;

  Item({
    required this.id,
    required this.name,
    required this.photoURL,
    // …,
    this.swapRequest,
  });

  // ✔️ Here’s the fixed signature using Map<String, dynamic>
  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // now returns Map<String, dynamic>
    return Item(
      id: doc.id,
      name: data['name'] as String,
      photoURL: data['photoURL'] as String,
      // … parse any other fields you need here …
      swapRequest:
          data['swapRequest'] != null
              ? SwapRequest.fromMap(data['swapRequest'] as Map<String, dynamic>)
              : null,
    );
  }
}
