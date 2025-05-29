/* // lib/models/item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SwapRequest {
  /* … your existing SwapRequest … */
}

class Item {
  final String id;
  final String name;
  final String photoURL;
  final String ownerId; // ← new!
  final SwapRequest? swapRequest;

  Item({
    required this.id,
    required this.name,
    required this.photoURL,
    required this.ownerId, // ← new!
    this.swapRequest,
  });

  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Item(
      id: doc.id,
      name: data['name'] as String,
      photoURL: data['photoURL'] as String,
      ownerId: data['ownerId'] as String, // ← parse ownerId
      swapRequest:
          data['swapRequest'] != null
              ? SwapRequest.fromMap(data['swapRequest'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'photoURL': photoURL,
    'ownerId': ownerId, // ← include ownerId
    if (swapRequest != null) 'swapRequest': swapRequest!.toMap(),
  };
}
 */