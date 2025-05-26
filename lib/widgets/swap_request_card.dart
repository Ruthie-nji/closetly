// lib/widgets/swap_request_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item.dart';

class SwapRequestCard extends StatelessWidget {
  /// The item the owner put up for swap
  final Item ownerItem;

  /// UID of the user who requested the swap
  final String requesterUid;

  /// The ID of the item the requester is offering
  final String offeredItemId;

  /// Called when owner taps “Accept”
  final VoidCallback onAccept;

  /// Called when owner taps “Reject”
  final VoidCallback onReject;

  const SwapRequestCard({
    super.key,
    required this.ownerItem,
    required this.requesterUid,
    required this.offeredItemId,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Swap Request',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // show both images side-by-side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Owner's item
                Column(
                  children: [
                    Image.network(
                      ownerItem.photoURL,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 4),
                    Text(ownerItem.name),
                  ],
                ),

                // Arrow icon
                const Icon(Icons.swap_horiz, size: 32),

                // Offered item loaded from Firestore
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(requesterUid)
                          .collection('items')
                          .doc(offeredItemId)
                          .get(),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final offeredItem = Item.fromDoc(snap.data!);
                    return Column(
                      children: [
                        Image.network(
                          offeredItem.photoURL,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 4),
                        Text(offeredItem.name),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Accept / Reject buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('Reject'),
                ),
                ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
