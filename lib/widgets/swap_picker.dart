// lib/widgets/swap_picker.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ← added
import '../models/item.dart';
import '../services/firestore_service.dart';

class SwapPicker extends StatelessWidget {
  final String ownerUid;
  final String theirItemId;

  const SwapPicker({
    super.key,
    required this.ownerUid,
    required this.theirItemId,
  });

  @override
  Widget build(BuildContext context) {
    // I need FirebaseAuth here
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // use the typed QuerySnapshot
      future:
          FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
              .collection('items')
              .get(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text('You have no items to offer.'));
        }
        // each doc is QueryDocumentSnapshot<Map<String,dynamic>>
        final items = snap.data!.docs.map((doc) => Item.fromDoc(doc)).toList();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return ListTile(
              leading: Image.network(
                item.photoURL,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(item.name),
              onTap: () {
                FirestoreService()
                    .requestSwap(
                      ownerUid: ownerUid,
                      theirItemId: theirItemId,
                      myOfferedItemId: item.id,
                    )
                    .then((_) => Navigator.of(context).pop());
              },
            );
          },
        );
      },
    );
  }
}
