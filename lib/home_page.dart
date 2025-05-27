// lib/home_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Import the AI recommendations page
import 'outfit_recommendations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _clothes = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Shoes',
    'Accessories',
  ];

  Future<void> _addClothingItem() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _clothes.add({
          'file': File(picked.path),
          'category': 'Tops', // default category
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            onPressed: _addClothingItem,
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.checkroom_rounded),
            onPressed: () {
              // Navigate to AI Outfit Recommendations
              final wardrobePaths =
                  _clothes.map((c) => (c['file'] as File).path).toList();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OutfitRecommendationsPage()),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
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

            // Search bar
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

            // Category chips
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

            // Pinterest-style grid
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
                      /* TODO: view full-size */
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addClothingItem,
        backgroundColor: const Color(0xFFFFB3C1),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
