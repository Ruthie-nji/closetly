// lib/home_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication utilities

// Import the AI-powered outfit recommendation screen
import 'outfit_recommendations_page.dart';

/// The main screen for the "Closetly Wardrobe" feature.
///
/// Displays the user's clothing items in a Pinterest-style grid,
/// allows adding new items via gallery, searching and filtering,
/// and provides quick access to sign-out and AI outfit recommendations.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A list to hold clothing items; each item has a local File and a category tag.
  final List<Map<String, dynamic>> _clothes = [];

  // Controller for the search TextField
  final TextEditingController _searchController = TextEditingController();

  // Tracks the currently selected category for filtering
  String _selectedCategory = 'All';

  // Predefined categories for clothing items
  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Shoes',
    'Accessories',
  ];

  /// Opens the gallery to let the user pick an image.
  /// On selection, adds the picked image to our local list with a default category.
  Future<void> _addClothingItem() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _clothes.add({
          'file': File(picked.path),
          'category':
              'Tops', // TODO: Prompt user to select actual category on add
        });
      });
    }
  }

  /// Signs the current user out via FirebaseAuth and
  /// navigates back to the login screen, clearing navigation history.
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Apply category and text search filters to the clothing list
    final filtered =
        _clothes.where((item) {
          final matchesCategory =
              _selectedCategory == 'All' ||
              item['category'] == _selectedCategory;
          final query = _searchController.text.trim().toLowerCase();
          final matchesSearch =
              query.isEmpty || item['category'].toLowerCase().contains(query);
          return matchesCategory && matchesSearch;
        }).toList();

    return Scaffold(
      // Transparent background to let gradient shine through
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Closetly Wardrobe',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => _signOut(context),
            color: Colors.white,
          ),
          // Add new clothing item button
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            onPressed: _addClothingItem,
            color: Colors.white,
          ),
          // Navigate to AI outfit recommendations
          IconButton(
            icon: const Icon(Icons.checkroom_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OutfitRecommendationsPage(),
                ),
              );
            },
            color: Colors.white,
          ),
        ],
      ),

      body: Container(
        // Background gradient for a soft, stylish look
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECE2C6), Color(0xFF8A9A5B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 24),

            // Search bar for quick filtering
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search clothes...',
                  filled: true,
                  fillColor: const Color(0xFFF5F5DC),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category selection chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children:
                    _categories.map((cat) {
                      final selected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: selected,
                          onSelected:
                              (_) => setState(() {
                                _selectedCategory = cat;
                              }),
                          backgroundColor: const Color(0xFFFFB3C1),
                          selectedColor: const Color(0xFFCFFF04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black26,
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Main grid displaying clothing items
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  return GestureDetector(
                    onTap: () {
                      // TODO: Show full-size preview or details overlay
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: FileImage(filtered[i]['file'] as File),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating button for quickly adding new items
      floatingActionButton: FloatingActionButton(
        onPressed: _addClothingItem,
        backgroundColor: const Color(0xFFFFB3C1),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
