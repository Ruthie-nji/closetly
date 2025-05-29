// lib/services/storage_service.dart

// Handles uploading photos to Firebase Storage (like Google Drive for our app)
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'dart:io' show File;

class StorageService {
  
  // Takes a bunch of photos and uploads them to the cloud
  // Returns web links where we can find them later
  static Future<List<String>> uploadWardrobe(List<XFile> images) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [];

    // Go through each photo one by one
    for (final xfile in images) {
      // Give each photo a unique name so they don't overwrite each other
      final filename = path.basename(xfile.path);
      final dest = 'user-uploads/${DateTime.now().millisecondsSinceEpoch}_$filename';
      final ref = storage.ref().child(dest);

      // Web browsers and mobile phones handle files differently
      if (kIsWeb) {
        // Web: Convert photo to bytes (computer language for images)
        final bytes = await xfile.readAsBytes();
        
        // Tell Firebase what kind of file this is (JPG, PNG, etc.)
        final metadata = SettableMetadata(contentType: xfile.mimeType);
        
        // Upload the bytes to Firebase
        await ref.putData(bytes, metadata);
      } else {
        // Mobile/Desktop: Use the file directly
        final file = File(xfile.path);
        await ref.putFile(file);
      }

      // Get the web address where people can view this photo
      final downloadUrl = await ref.getDownloadURL();
      urls.add(downloadUrl);
    }

    // Return all the web addresses
    return urls;
  }
}
