// inside your item grid builder:
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/item.dart';
import '../widgets/swap_request_card.dart';
import '../services/firestore_service.dart';
import '../widgets/item_card.dart';
import '../widgets/swap_picker.dart';

class FriendWardrobePage extends StatelessWidget {
  /// The UID of the friend whose wardrobe we're viewing
  final String friendUid;

  const FriendWardrobePage({super.key, required this.friendUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friend's Wardrobe")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(friendUid)
                .collection('items')
                .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(child: Text("No items found."));
          }

          final docs = snap.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final friendItem = Item.fromDoc(docs[i]);

              return ItemCard(
                item: friendItem,
                trailing: ElevatedButton(
                  onPressed:
                      friendItem.swapRequest == null
                          ? () {
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (_) => SwapPicker(
                                    ownerUid: friendUid,
                                    theirItemId: friendItem.id,
                                  ),
                            );
                          }
                          : null,
                  child: const Text('Request Swap'), // disable if there’s already a pending request
                ),
              );
            },
          );
        },
      ),
    );
  }
}
