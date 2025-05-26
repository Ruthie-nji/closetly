// lib/widgets/item_card.dart

import 'package:flutter/material.dart';
import '../models/item.dart';

/// A simple card showing an item's image, name, and an optional trailing widget.
class ItemCard extends StatelessWidget {
  final Item item;
  final Widget? trailing;

  const ItemCard({
    super.key,
    required this.item,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                item.photoURL,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: trailing,
            ),
        ],
      ),
    );
  }
}
