// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends a swap request by embedding a `swapRequest` map on the friend's item
  Future<void> requestSwap({
    required String ownerUid,
    required String theirItemId,
    required String myOfferedItemId,
  }) {
    final currentUid = _auth.currentUser!.uid;
    final itemRef = _db
        .collection('users')
        .doc(ownerUid)
        .collection('items')
        .doc(theirItemId);

    return itemRef.update({
      'swapRequest': {
        'from': currentUid,
        'offeredItemId': myOfferedItemId,
        'status': 'pending',
        'at': FieldValue.serverTimestamp(),
      },
    });
  }

  /// Accepts or rejects a pending swap in a single atomic transaction
  Future<void> respondSwap({
    required String ownerUid,
    required String ownerItemId,
    required String requesterUid,
    required String requesterItemId,
    required bool accept,
  }) {
    final ownerRef = _db
        .collection('users')
        .doc(ownerUid)
        .collection('items')
        .doc(ownerItemId);
    final requesterRef = _db
        .collection('users')
        .doc(requesterUid)
        .collection('items')
        .doc(requesterItemId);

    return _db.runTransaction((tx) async {
      // Load the owner's item
      final ownerSnap =
          await tx.get(ownerRef);

      if (!accept) {
        // On reject: just clear the swapRequest field
        tx.update(ownerRef, {'swapRequest': FieldValue.delete()});
        return;
      }

      // On accept: swap the two documents
      final requesterSnap =
          await tx.get(requesterRef);

      final ownerData = ownerSnap.data()!;
      final requesterData = requesterSnap.data()!;

      // 1) Clear the request on the owner's document
      tx.update(ownerRef, {'swapRequest': FieldValue.delete()});

      // 2) Swap the item data under each user
      tx.set(requesterRef, ownerData);
      tx.set(ownerRef, requesterData);
    });
  }
}
