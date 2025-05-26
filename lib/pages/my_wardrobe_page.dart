// lib/pages/my_wardrobe_page.dart

import 'package:flutter/material.dart';

class MyWardrobePage extends StatelessWidget {
  const MyWardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Wardrobe')),
      body: Center(child: Text('✅ MyWardrobePage is loaded')),
    );
  }
}




























// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../models/item.dart';
// import '../widgets/swap_request_card.dart';
// import '../services/firestore_service.dart';
// import '../widgets/item_card.dart';
// import '../widgets/swap_picker.dart';

// class MyWardrobePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final myUid = FirebaseAuth.instance.currentUser!.uid;
//     return Scaffold(
//       appBar: AppBar(title: Text('My Wardrobe')),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream:
//             FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(myUid)
//                 .collection('items')
//                 .snapshots(),
//         builder: (ctx, snap) {
//           if (!snap.hasData) return Center(child: CircularProgressIndicator());
//           final docs = snap.data!.docs;
//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//             ),
//             itemCount: docs.length,
//             itemBuilder: (ctx, i) {
//               final itemId = docs[i].id;
//               return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//                 stream:
//                     FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(myUid)
//                         .collection('items')
//                         .doc(itemId)
//                         .snapshots(),
//                 builder: (ctx, snap) {
//                   if (!snap.hasData)
//                     return Center(child: CircularProgressIndicator());
//                   final item = Item.fromDoc(snap.data!);

//                   if (item.swapRequest?.status == 'pending') {
//                     return SwapRequestCard(
//                       ownerItem: item,
//                       requesterUid: item.swapRequest!.fromUid,
//                       offeredItemId: item.swapRequest!.offeredItemId,
//                       onAccept:
//                           () => FirestoreService().respondSwap(
//                             ownerUid: myUid,
//                             ownerItemId: item.id,
//                             requesterUid: item.swapRequest!.fromUid,
//                             requesterItemId: item.swapRequest!.offeredItemId,
//                             accept: true,
//                           ),
//                       onReject:
//                           () => FirestoreService().respondSwap(
//                             ownerUid: myUid,
//                             ownerItemId: item.id,
//                             requesterUid: item.swapRequest!.fromUid,
//                             requesterItemId: item.swapRequest!.offeredItemId,
//                             accept: false,
//                           ),
//                     );
//                   }

//                   return ItemCard(item: item);
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
