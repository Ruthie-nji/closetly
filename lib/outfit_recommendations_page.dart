import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'outfit.dart';

/// Displays AI-powered outfit recommendations based on the user's wardrobe.
class OutfitRecommendationsPage extends StatefulWidget {
  /// Pass in a list of wardrobe image URLs or local file paths.
  final List<String> wardrobePaths;

  const OutfitRecommendationsPage({
    super.key,
    required this.wardrobePaths,
  });

  @override
  State<OutfitRecommendationsPage> createState() => _OutfitRecommendationsPageState();
}

class _OutfitRecommendationsPageState extends State<OutfitRecommendationsPage> {
  List<Outfit> _outfits = [];
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
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() => _outfits = []);
    try {
      final recs = await AiService.getOutfits(
        imageUrls: widget.wardrobePaths,
        category: _selectedCategory,
      );
      setState(() => _outfits = recs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching outfits: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Earth-toned gradient background
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
          // Decorative blobs
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
                Text(
                  'Outfit Inspo',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.brown.shade800,
                    shadows: [Shadow(blurRadius: 8, color: Colors.white38)],
                  ),
                ),
                const SizedBox(height: 12),
                // Category chips
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
                            setState(() => _selectedCategory = cat);
                            _fetchRecommendations();
                          },
                          selectedColor: Colors.brown.shade700,
                          backgroundColor: Colors.brown.shade200.withOpacity(0.7),
                          elevation: selected ? 4 : 0,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // AI results
                Expanded(
                  child: _outfits.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : PageView.builder(
                          controller: PageController(viewportFraction: 0.85),
                          itemCount: _outfits.length,
                          itemBuilder: (ctx, i) => _OutfitCard(outfit: _outfits[i]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color c, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.withOpacity(0.6), c.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(size),
        ),
      );
}

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
            // Horizontal thumbnails
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: outfit.imageUrls.map((url) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(url, width: 100, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Y2K-style stripe
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB0E4C4), Color(0xFFFFCAD4), Color(0xFFC1A4E8)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Text(
              outfit.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade400),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade400),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
