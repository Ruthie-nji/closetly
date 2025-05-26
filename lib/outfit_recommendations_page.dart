// lib/outfit_recommendations_page.dart

import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'outfit.dart';

/// I show AI-powered outfit suggestions based on what the user has uploaded.
class OutfitRecommendationsPage extends StatefulWidget {
  /// I accept a list of image paths or data to feed into my AI service.
  final List<String> wardrobePaths;

  const OutfitRecommendationsPage({super.key, required this.wardrobePaths});

  @override
  State<OutfitRecommendationsPage> createState() =>
      _OutfitRecommendationsPageState();
}

class _OutfitRecommendationsPageState extends State<OutfitRecommendationsPage> {
  // I keep track of the outfits that the AI returns.
  List<Outfit> _outfits = [];

  // I let users filter suggestions by occasion.
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Work',
    'Casual',
    'Date Night',
    'Weekend',
  ];

  @override
  void initState() {
    super.initState();
    // As soon as this page loads, I fetch AI recommendations.
    _fetchRecommendations();
  }

  /// I call my AI service and update state with the new outfits.
  Future<void> _fetchRecommendations() async {
    // I clear out old suggestions to show a loading state.
    setState(() => _outfits = []);

    try {
      // I ask the AI for outfits, passing along the images and selected filter.
      final recs = await AiService.getOutfits(
        imageUrls: widget.wardrobePaths,
        category: _selectedCategory,
      );
      // I store whatever the AI returns so the UI can update.
      setState(() => _outfits = recs);
    } catch (e) {
      // If something goes wrong, I let the user know via a SnackBar.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching outfits: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // I layer an earth-toned gradient as my background.
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3D7C6), Color(0xFF8C9A73)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // I add some fun decorative blobs to make it feel lively.
          Positioned(
            top: -80,
            left: -60,
            child: _buildBlob(Colors.tealAccent.shade100, 200),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _buildBlob(Colors.pinkAccent.shade100, 240),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // I display my page title with a bit of style.
                Text(
                  'Outfit Inspo',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.brown.shade800,
                    shadows: [Shadow(blurRadius: 8, color: Colors.white38)],
                  ),
                ),
                const SizedBox(height: 12),

                // I let users choose from different outfit categories.
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.brown,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            // When the user picks a new category, I refetch.
                            setState(() => _selectedCategory = cat);
                            _fetchRecommendations();
                          },
                          selectedColor: Colors.brown.shade700,
                          backgroundColor: Colors.brown.shade200.withOpacity(
                            0.7,
                          ),
                          elevation: selected ? 4 : 0,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // I show a loading spinner if I haven't gotten outfits yet.
                Expanded(
                  child:
                      _outfits.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          // Otherwise, I let the user swipe through suggestion cards.
                          : PageView.builder(
                            controller: PageController(viewportFraction: 0.85),
                            itemCount: _outfits.length,
                            itemBuilder:
                                (ctx, i) => _OutfitCard(outfit: _outfits[i]),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// I build a soft, rounded blob shape for decoration.
  Widget _buildBlob(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
      ),
      borderRadius: BorderRadius.circular(size),
    ),
  );
}

/// I encapsulate each outfit suggestion as its own card widget.
class _OutfitCard extends StatelessWidget {
  final Outfit outfit;

  const _OutfitCard({required this.outfit});

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            // I show a horizontal scroll of thumbnail images for each outfit piece.
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    outfit.imageUrls.map((url) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            url,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            // I insert a fun Y2K-style stripe divider under the images.
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFB0E4C4),
                    Color(0xFFFFCAD4),
                    Color(0xFFC1A4E8),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // I display the outfit title in a bold font.
            Text(
              outfit.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // I give users buttons to save or share their favorite suggestions.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade400,
                  ),
                  onPressed: () {
                    // TODO: wire up save action
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade400,
                  ),
                  onPressed: () {
                    // TODO: wire up share action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
