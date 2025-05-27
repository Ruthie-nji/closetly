// lib/services/storage_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'dart:io' show File;

class StorageService {
  /// Uploads each picked XFile to Firebase Storage under `user-uploads/`
  /// and returns a list of their download URLs.
  static Future<List<String>> uploadWardrobe(List<XFile> images) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [];

    for (final xfile in images) {
      // Build a unique destination path
      final filename = path.basename(xfile.path);
      final dest =
          'user-uploads/${DateTime.now().millisecondsSinceEpoch}_$filename';
      final ref = storage.ref().child(dest);

      // Web: read bytes & use putData
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        // Optionally grab the MIME type for metadata:
        final metadata = SettableMetadata(contentType: xfile.mimeType);
        await ref.putData(bytes, metadata);
      } else {
        // Mobile/Desktop: use the File class
        final file = File(xfile.path);
        await ref.putFile(file);
      }

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      urls.add(downloadUrl);
    }

    return urls;
  }
}
