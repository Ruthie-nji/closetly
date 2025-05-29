// lib/pages/outfit_recommendations_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/outfit.dart';
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

  // Tracks whether we're waiting for uploads or AI responses
  bool _isLoading = false;

  // Raw URLs for uploaded images (can be used for debugging)
  List<String> _uploadedImageUrls = [];

  // Our list of outfit suggestions to display
  List<Outfit> _outfits = [];

  // Example category selector (not used in dummy mode)
  final String _selectedCategory = 'All';

  /// This method drives the user flow:
  /// 1. Pick multiple images
  /// 2. Upload them to Firebase Storage
  /// 3. Call our AI service for recommendations
  /// 4. Display results in a grid
  Future<void> _pickAndFetch() async {
    // Let user pick multiple images from gallery
    final List<XFile> pics = await _picker.pickMultiImage();
    if (pics.isEmpty) return;

    // Show loading spinner
    setState(() {
      _isLoading = true;
      _uploadedImageUrls = [];
      _outfits = [];
    });

    // ----------------- DUMMY DATA MODE -----------------
    // Right now our AI backend is returning an empty list,
    // i threw  in some pretend outfits until that
    // gets ramped up. This also proves our UI works!
    await Future.delayed(const Duration(milliseconds: 700));
    final dummy = <Outfit>[
      Outfit(
        title: 'Casual Denim Look',
        imageUrls: ['https://via.placeholder.com/300x400'],
      ),
      Outfit(
        title: 'Sporty Athleisure',
        imageUrls: ['https://via.placeholder.com/300x400'],
      ),
    ];
    setState(() {
      _outfits = dummy;
      _isLoading = false;
    });
    return; // Stop here while in dummy mode
    // ---------------------------------------------------

    // When your AI service is ready, comment out the dummy block
    // above and uncomment the real flow below:

    /*
    try {
      // Step 1: upload images and collect URLs
      final List<String> urls = await StorageService.uploadWardrobe(pics);
      setState(() => _uploadedImageUrls = urls);

      // Step 2: call AI backend
      final List<Outfit> recs = await AiService.getOutfits(
        imageUrls: urls,
        category: _selectedCategory,
      );

      // Step 3: show suggestions
      setState(() {
        _outfits = recs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recommendations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Button to start the flow
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick & Upload Photos'),
              onPressed: _isLoading ? null : _pickAndFetch,
            ),

            const SizedBox(height: 16),

            // Show a spinner while loading
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Once we have outfits, show them in a grid
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Show the first image
                          if (outfit.imageUrls.isNotEmpty)
                            Expanded(
                              child: Image.network(
                                outfit.imageUrls.first,
                                fit: BoxFit.cover,
                              ),
                            ),

                          // And the title below
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              outfit.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // If no outfits yet (and not loading), show a friendly hint
            if (!_isLoading && _outfits.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Upload some photos to see outfit suggestions!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
