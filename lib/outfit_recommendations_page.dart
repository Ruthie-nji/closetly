// lib/pages/outfit_recommendations_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class OutfitRecommendationsPage extends StatefulWidget {
  const OutfitRecommendationsPage({super.key});

  @override
  _OutfitRecommendationsPageState createState() =>
      _OutfitRecommendationsPageState();
}

class _OutfitRecommendationsPageState extends State<OutfitRecommendationsPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<Outfit> _outfits = [];
  final String _selectedCategory = 'All';

  Future<void> _pickAndFetch() async {
    // 1) Let user pick multiple images
    final List<XFile> pics = await _picker.pickMultiImage();
    if (pics == null || pics.isEmpty) return;

    setState(() {
      _isLoading = true;
      _outfits = [];
    });

    try {
      // 2) Upload images and get download URLs
      final List<String> urls = await StorageService.uploadWardrobe(pics);

      // 3) Fetch outfit recommendations from AI service
      final List<Outfit> recs = await AiService.getOutfits(
        imageUrls: urls,
        category: _selectedCategory,
      );

      setState(() {
        _outfits = recs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick & Upload Photos'),
              onPressed: _isLoading ? null : _pickAndFetch,
            ),

            const SizedBox(height: 16),

            if (_isLoading) const Center(child: CircularProgressIndicator()),

            if (!_isLoading && _outfits.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _outfits.length,
                  itemBuilder: (context, i) {
                    final outfit = _outfits[i];
                    return Card(
                      elevation: 3,
                      child: Column(
                        children: [
                          Image.network(
                            outfit.imageUrl,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              outfit.description,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            if (!_isLoading && _outfits.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Upload photos to see outfit suggestions.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
